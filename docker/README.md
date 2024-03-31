These docker containers are used for running unit tests in different
environments. Specifically, running this plugin with different plugin managers.

If you are developing locally, you can test your changes before pushing like so:

Build the container:

```
make build-lazy
```

Run the tests:

```
make run-lazy
```
