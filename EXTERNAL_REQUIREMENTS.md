For the JetBrains restriction specifically, you need just these two files, which I verified remotely:

  - purejavacomm-0.0.11.1.jar (https://packages.jetbrains.team/maven/p/ij/intellij-dependencies/org/jetbrains/pty4j/purejavacomm/0.0.11.1/purejavacomm-0.0.11.1.jar)
  - purejavacomm-0.0.11.1.pom (https://packages.jetbrains.team/maven/p/ij/intellij-dependencies/org/jetbrains/pty4j/purejavacomm/0.0.11.1/purejavacomm-0.0.11.1.pom)

  The POM has no additional dependencies. Sources and Javadoc JARs are not needed for building.

  Using an approved transfer mechanism, these can be installed into the container’s Maven cache with:

  mvn install:install-file \
    -Dfile=/downloads/purejavacomm-0.0.11.1.jar \
    -DpomFile=/downloads/purejavacomm-0.0.11.1.pom

  That command runs inside the Maven container, with /downloads mounted to the transferred files and the existing jeditermfx-m2 volume mounted as before. The install plugin itself needs
  to be cached or reachable through Central.

  Other Non-Central Files
  If Repsy is also restricted, the current build uses these files. Paths below are relative to:

  https://repo.repsy.io/mvn/techsenger/snapshots/

  com/techsenger/maven/root/maven-root/1.6.0-SNAPSHOT/
    maven-metadata.xml
    maven-root-1.6.0-20251017.210050-3.pom

  com/techsenger/osp/bom/osp-bom/1.7.0-SNAPSHOT/
    maven-metadata.xml
    osp-bom-1.7.0-20251218.235526-6.pom

  com/techsenger/checkstyle/config/checkstyle-config/1.1.0-SNAPSHOT/
    maven-metadata.xml
    checkstyle-config-1.1.0-20251020.210318-4.pom
    checkstyle-config-1.1.0-20251020.210318-4.jar

  These are the currently published snapshot filenames. Include the Checkstyle files because Maven can resolve plugin dependencies even when the check itself is skipped. The other
  identified third-party dependencies are available from Maven Central.

  External Build Plan
  Your external-network approach makes sense. One important distinction: pulling source changes from GitHub does not bring back the dependency cache.

  For a reproducible local build, bring back these separately through your approved process:

  - Sanitized source/build changes through GitHub.
  - The populated Maven repository from the container’s /root/.m2/repository.
  - The build container image, if your local environment cannot pull it.

  Before transferring the cache, verify it externally by rebuilding with networking disabled:

  podman run --rm --network=none \
    -v "$PWD":/workspace:Z \
    -v jeditermfx-m2:/root/.m2 \
    -w /workspace \
    docker.io/library/maven:3.9-eclipse-temurin-17 \
    mvn -o -B clean install

  Repeat that offline check after completing the Java 8 port, since its dependencies may differ. Keep the cache out of Git, and do not transfer Maven credentials or settings.xml
  containing secrets.


