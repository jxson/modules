// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// A convenience user shell that launches an email story full screen.

#include "apps/maxwell/services/suggestion/suggestion_provider.fidl.h"
#include "apps/modular/lib/app/connect.h"
#include "apps/modular/lib/fidl/array_to_string.h"
#include "apps/modular/lib/fidl/single_service_view_app.h"
#include "apps/modular/lib/fidl/strong_binding.h"
#include "apps/modular/services/application/service_provider.fidl.h"
#include "apps/modular/services/user/focus.fidl.h"
#include "apps/modular/services/user/user_shell.fidl.h"
#include "apps/mozart/lib/view_framework/base_view.h"
#include "apps/mozart/services/views/view_manager.fidl.h"
#include "apps/mozart/services/views/view_provider.fidl.h"
#include "apps/mozart/services/views/view_token.fidl.h"
#include "lib/fidl/cpp/bindings/binding.h"
#include "lib/ftl/functional/make_copyable.h"
#include "lib/ftl/logging.h"
#include "lib/ftl/macros.h"
#include "lib/ftl/tasks/task_runner.h"
#include "lib/ftl/time/time_delta.h"
#include "lib/mtl/tasks/message_loop.h"

namespace {

constexpr char kEmailStoryUrl[] = "file:///system/apps/email_story";

constexpr uint32_t kRootNodeId = mozart::kSceneRootNodeId;
constexpr uint32_t kViewResourceIdBase = 100;

class EmailUserShellView : public mozart::BaseView {
 public:
  explicit EmailUserShellView(
      mozart::ViewManagerPtr view_manager,
      fidl::InterfaceRequest<mozart::ViewOwner> view_owner_request)
      : BaseView(std::move(view_manager),
                 std::move(view_owner_request),
                 "EmailUserShellView") {}

  ~EmailUserShellView() override = default;

  void ConnectView(fidl::InterfaceHandle<mozart::ViewOwner> view_owner) {
    GetViewContainer()->AddChild(++child_view_key_, std::move(view_owner));
  }

 private:
  // |mozart::BaseView|
  void OnChildAttached(uint32_t child_key,
                       mozart::ViewInfoPtr child_view_info) override {
    view_info_ = std::move(child_view_info);
    auto view_properties = mozart::ViewProperties::New();
    GetViewContainer()->SetChildProperties(child_view_key_, 0 /* scene_token */,
                                           std::move(view_properties));
    Invalidate();
  }

  // |mozart::BaseView|
  void OnChildUnavailable(uint32_t child_key) override {
    view_info_.reset();
    GetViewContainer()->RemoveChild(child_key, nullptr);
    Invalidate();
  }

  // |mozart::BaseView|
  void OnDraw() override {
    FTL_DCHECK(properties());

    auto update = mozart::SceneUpdate::New();
    auto root_node = mozart::Node::New();

    if (view_info_) {
      const uint32_t scene_resource_id = kViewResourceIdBase + child_view_key_;
      auto scene_resource = mozart::Resource::New();
      scene_resource->set_scene(mozart::SceneResource::New());
      scene_resource->get_scene()->scene_token =
          view_info_->scene_token.Clone();
      update->resources.insert(scene_resource_id, std::move(scene_resource));
      root_node->op = mozart::NodeOp::New();
      root_node->op->set_scene(mozart::SceneNodeOp::New());
      root_node->op->get_scene()->scene_resource_id = scene_resource_id;
    }

    update->nodes.insert(kRootNodeId, std::move(root_node));
    scene()->Update(std::move(update));
    scene()->Publish(CreateSceneMetadata());
  }

  mozart::ViewInfoPtr view_info_;
  uint32_t child_view_key_{};

  FTL_DISALLOW_COPY_AND_ASSIGN(EmailUserShellView);
};

class EmailUserShellApp
    : public modular::SingleServiceViewApp<modular::UserShell> {
 public:
  explicit EmailUserShellApp() {}
  ~EmailUserShellApp() override = default;

 private:
  // |SingleServiceViewApp|
  void CreateView(
      fidl::InterfaceRequest<mozart::ViewOwner> view_owner_request,
      fidl::InterfaceRequest<modular::ServiceProvider> services) override {
    view_.reset(new EmailUserShellView(
        application_context()
            ->ConnectToEnvironmentService<mozart::ViewManager>(),
        std::move(view_owner_request)));
  }

  // |UserShell|
  void Initialize(fidl::InterfaceHandle<modular::StoryProvider> story_provider,
                  fidl::InterfaceHandle<maxwell::SuggestionProvider>
                      suggestion_provider,
                  fidl::InterfaceRequest<modular::FocusController>
                      focus_controller_request) override {
    story_provider_.Bind(std::move(story_provider));
    CreateStory(kEmailStoryUrl);
  }

  void CreateStory(const fidl::String& url) {
    FTL_LOG(INFO) << "EmailUserShell::CreateStory() " << url;
    story_provider_->CreateStory(url, fidl::GetProxy(&story_controller_));
    story_controller_->GetInfo([this](modular::StoryInfoPtr story_info) {
      InitStory();
    });
  }

  void ResumeStory() {}

  void InitStory() {
    FTL_LOG(INFO) << "EmailUserShellView::InitStory()";
    fidl::InterfaceHandle<mozart::ViewOwner> story_view;
    story_controller_->Start(fidl::GetProxy(&story_view));

    // Show the new story, if we have a view.
    if (view_) {
      view_->ConnectView(std::move(story_view));
    }
  }

  std::unique_ptr<EmailUserShellView> view_;

  modular::StoryProviderPtr story_provider_;
  modular::StoryControllerPtr story_controller_;

  FTL_DISALLOW_COPY_AND_ASSIGN(EmailUserShellApp);
};

}  // namespace

int main(int argc, const char** argv) {
  mtl::MessageLoop loop;
  EmailUserShellApp app;
  loop.Run();
  return 0;
}
