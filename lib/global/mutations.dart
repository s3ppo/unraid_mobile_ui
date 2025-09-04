class Mutations {
  static const String stopDocker = r'''
    mutation Stop($dockerId: PrefixedID!) {
      docker {
        stop(id: $dockerId) {
          id, names, image, imageId, command, created, sizeRootFs, labels, state, status, networkSettings, mounts, autoStart
        }
      }
    }
  ''';

  static const String startDocker = r'''
    mutation Start($dockerId: PrefixedID!) {
      docker {
        start(id: $dockerId) {
          id, names, image, imageId, command, created, sizeRootFs, labels, state, status, networkSettings, mounts, autoStart
        }
      }
    }
  ''';

  static const String stopVM = r'''
    mutation Stop($vmId: PrefixedID!) {
      vm {
        stop(id: $vmId)
      }
    }
  ''';

  static const String startVM = r'''
    mutation Start($vmId: PrefixedID!) {
      vm {
        start(id: $vmId)
      }
    }
  ''';

  static const String pauseVM = r'''
    mutation Pause($vmId: PrefixedID!) {
      vm {
        pause(id: $vmId)
      }
    }
  ''';

  static const String resumeVM = r'''
    mutation Resume($vmId: PrefixedID!) {
      vm {
        resume(id: $vmId)
      }
    }
  ''';

  static const String forceStopVM = r'''
    mutation ForceStop($vmId: PrefixedID!) {
      vm {
        forceStop(id: $vmId)
      }
    }
  ''';

  static const String rebootVM = r'''
    mutation Reboot($vmId: PrefixedID!) {
      vm {
        reboot(id: $vmId)
      }
    }
  ''';

  static const String resetVM = r'''
    mutation Reset($vmId: PrefixedID!) {
      vm {
        reset(id: $vmId)
      }
    }
  ''';  

  static const String setArrayState = r'''
    mutation SetState($input: ArrayStateInput!) {
      array {
        setState(input: $input) {
          state
        }
      }
    }
  ''';

  static const String startParityCheck = r'''
    mutation Start($correct: Boolean!) {
      parityCheck {
        start(correct: $correct)
      }
    }
  ''';

  static const String pauseParityCheck = r'''
    mutation Pause {
      parityCheck {
        pause
      }
    }
  ''';

  static const String resumeParityCheck = r'''
    mutation Resume {
      parityCheck {
        resume
      }
    }
  ''';

  static const String cancelParityCheck = r'''
    mutation Cancel {
      parityCheck {
        cancel
      }
    }
  ''';

}
