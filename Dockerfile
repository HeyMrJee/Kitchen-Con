image_config: &image_config

  # make sure to set your Docker Hub username & password in CircleCI,
  # either as project-specific environment variables
  # or as resources in your organization's org-global Context

  IMAGE_NAME: chicken-test

  IMAGE_TAG: 0.0.3

  # NOTE: if you're modifying this config.yml file manually
  # rather than using the included setup script,
  # make sure you also add the values of your IMAGE_NAME & IMAGE_TAG variables
  # to the `test_image` job (line 55)

  LINUX_VERSION: UBUNTU_XENIAL

  RUBY_VERSION_NUM: 2.4.2

  # NODE_VERSION_NUM: # pick a version from https://nodejs.org/dist

  # PYTHON_VERSION_NUM: # pick a version from https://python.org/ftp/python

  JAVA: false

  MYSQL_CLIENT: false

  POSTGRES_CLIENT: false

  DOCKERIZE: true

  BROWSERS: false

version: 2
jobs:
  build:
    machine: true
    environment:
      <<: *image_config

    steps:
      - checkout

      - run: bash scripts/generate.sh > Dockerfile

      - run: docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

      - run: docker build -t $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG .

      - run: docker push $DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG && sleep 10

      - store_artifacts:
          path: Dockerfile

  test_image:
    docker:
      - image: $DOCKER_USERNAME/chicken-test:0.0.3
        environment:
          <<: *image_config

    steps:
      - checkout

      #- run:
      #    name: start Xvfb for phantomjs test
          # command: Xvfb :99
          # background: true

      - run:
          name: bats tests
          command: |
            mkdir -p test_results/bats
            bats scripts/tests.bats | \
            perl scripts/tap-to-junit.sh > \
            test_results/bats/results.xml
      - store_test_results:
          path: test_results

      - store_artifacts:
          path: test_results

workflows:
  version: 2
  dockerfile_wizard:
    jobs:
      - build:
          context: org-global
      - test_image:
          context: org-global
          requires:
            - build
