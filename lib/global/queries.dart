class Queries {
  static const String getDockers = r'''
    query Query{
      docker { containers { id, names, image, imageId, command, created, sizeRootFs, labels, state, status, networkSettings, mounts, autoStart } } 
    }
  ''';

  static const String getVms = r'''
    query Query {
      vms { domain { uuid, name, state } }
    }
  ''';

  static const String getArray = r'''
    query Query { array {
      state
      boot {
        id, name, status, size
      }
      disks {
        id, name, status, size
      }
      parities {
        id, name, status, size
      }
      caches {
        id, name, status, size
      }
    } }
  ''';

  static const String getShares = r'''
    query Query {
      shares {
        name
        free
        used
        size
        include
        exclude
        cache
        nameOrig
        comment
        allocator
        splitLevel
        floor
        cow
        color
        luksStatus
      }
    }
  ''';

  static const String getServices = r'''
    query {
      services {
        id
        name
        version
      }
    }
  ''';

  static const String getInfo = r'''
      query {
        info {
          cpu {
            manufacturer
            brand
            vendor
            family
            model
            stepping
            revision
            voltage
            speed
            speedmin
            speedmax
            threads
            cores
            processors
            socket
            cache
          }
          baseboard {
            manufacturer
            model
            version
            serial
            assetTag
          }
          os {
            platform
            distro
            release
            codename
            kernel
            arch
            hostname
            codepage
            logofile
            serial
            build
            uptime
          }
          memory {
            max
            total
            free
            used
            active
            available
            buffcache
            swaptotal
            swapused
            swapfree
          }
        }
      }
  ''';
}
