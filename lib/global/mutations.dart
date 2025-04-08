class Mutations {
  static const String stopDocker = r'''
    mutation StopContainer($dockerId: ID!) {
      docker {
        stop(id: $dockerId) {
          id, names, image, imageId, command, created, sizeRootFs, labels, state, status, networkSettings, mounts, autoStart
        }
      }
    }
  ''';

  static const String startDocker = r'''
    mutation StartContainer($dockerId: ID!) {
      docker {
        start(id: $dockerId) {
          id, names, image, imageId, command, created, sizeRootFs, labels, state, status, networkSettings, mounts, autoStart
        }
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

}
