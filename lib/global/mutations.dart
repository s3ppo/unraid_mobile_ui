class Mutations {
  static const String stopDocker = r'''
    mutation Stop($dockerId: String!) {
      docker {
        stop(id: $dockerId) {
          id, names, image, imageId, command, created, sizeRootFs, labels, state, status, networkSettings, mounts, autoStart
        }
      }
    }
  ''';

  static const String startDocker = r'''
    mutation Start($dockerId: String!) {
      docker {
        start(id: $dockerId) {
          id, names, image, imageId, command, created, sizeRootFs, labels, state, status, networkSettings, mounts, autoStart
        }
      }
    }
  ''';

  static const String stopVM = r'''
    mutation Stop($vmId: String!) {
      vm {
        stop(id: $vmId)
      }
    }
  ''';

  static const String startVM = r'''
    mutation Start($vmId: String!) {
      vm {
        start(id: $vmId)
      }
    }
  ''';

  static const String pauseVM = r'''
    mutation Pause($vmId: String!) {
      vm {
        pause(id: $vmId)
      }
    }
  ''';

  static const String resumeVM = r'''
    mutation Resume($vmId: String!) {
      vm {
        resume(id: $vmId)
      }
    }
  ''';

  static const String forceStopVM = r'''
    mutation ForceStop($vmId: String!) {
      vm {
        forceStop(id: $vmId)
      }
    }
  ''';

  static const String rebootVM = r'''
    mutation Reboot($vmId: String!) {
      vm {
        reboot(id: $vmId)
      }
    }
  ''';

  static const String resetVM = r'''
    mutation Reset($vmId: String!) {
      vm {
        reset(id: $vmId)
      }
    }
  ''';  

  static const String setArrayState = r'''
    mutation SetState($input: ArrayStateInput) {
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
