// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:application.lib.app.dart/app.dart';
import 'package:application.services/service_provider.fidl.dart';
import 'package:apps.maxwell.services.suggestion/proposal_publisher.fidl.dart';
import 'package:apps.modular.services.agent/agent.fidl.dart';
import 'package:apps.modular.services.agent/agent_context.fidl.dart';
import 'package:apps.modular.services.component/component_context.fidl.dart';
import 'package:apps.modules.email.services/email_content_provider.fidl.dart'
    as ecp;
import 'package:lib.fidl.dart/bindings.dart';

import 'src/content_provider_impl.dart';

final ApplicationContext _context = new ApplicationContext.fromStartupInfo();
EmailContentProviderAgent _agent;

void _log(String msg) {
  print('[email_agent] $msg');
}

/// An implementation of the [Agent] interface.
class EmailContentProviderAgent extends Agent {
  // TOOD(vardhan): Need a proper BindingSet that self-removes dead interfaces.
  // (Issue US-174)
  AgentBinding _agentBinding;
  ComponentContextProxy _componentContext;

  /// Provides the [EmailContentProvider] service.
  /// TODO(vardhan): A ServiceProviderImpl should suport multiple bindings.
  /// (Issue US-174)
  final ServiceProviderImpl _outgoingServicesImpl = new ServiceProviderImpl();
  final List<ServiceProviderBinding> _outgoingServicesBindings =
      new List<ServiceProviderBinding>();

  EmailContentProviderImpl _emailContentProviderImpl;

  /// Constructor.
  EmailContentProviderAgent(InterfaceRequest<Agent> request) {
    _agentBinding = new AgentBinding()..bind(this, request);
  }

  /// Implements [Agent] interface.
  @override
  Future<Null> initialize(
      InterfaceHandle<AgentContext> agentContextHandle) async {
    _log('Initialize called');

    // Get the ComponentContext
    AgentContextProxy agentContext = new AgentContextProxy()
      ..ctrl.bind(agentContextHandle);
    _componentContext = new ComponentContextProxy();
    agentContext.getComponentContext(_componentContext.ctrl.request());

    // Get the ProposalPublisher
    ProposalPublisherProxy proposalPublisher = new ProposalPublisherProxy();
    connectToService(_context.environmentServices, proposalPublisher.ctrl);

    _emailContentProviderImpl =
        new EmailContentProviderImpl(_componentContext, proposalPublisher);

    _outgoingServicesImpl.addServiceForName(
        (InterfaceRequest<ecp.EmailContentProvider> request) async {
      _emailContentProviderImpl.addBinding(request);
    }, ecp.EmailContentProvider.serviceName);

    await _emailContentProviderImpl.init();
  }

  /// Implements [Agent] interface.
  @override
  void connect(
      String requestorUrl, InterfaceRequest<ServiceProvider> services) {
    _outgoingServicesBindings.add(
        new ServiceProviderBinding()..bind(_outgoingServicesImpl, services));
  }

  /// Implements [Agent] interface.
  @override
  void runTask(String taskId, void callback()) {}

  /// Implements [Agent] interface.
  @override
  void stop(void callback()) {
    _log('Stop called');

    _emailContentProviderImpl.close();
    _outgoingServicesBindings
        .forEach((ServiceProviderBinding binding) => binding.close());
    callback();
  }
}

/// Main entry point.
Future<Null> main(List<String> args) async {
  _context.outgoingServices.addServiceForName(
      (InterfaceRequest<Agent> request) {
    if (_agent == null) {
      _agent = new EmailContentProviderAgent(request);
    } else {
      // Can only connect to this interface once.
      request.close();
    }
  }, Agent.serviceName);
}
