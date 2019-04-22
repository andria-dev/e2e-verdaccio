# e2e-verdaccio

This is a script that you can use to test publishing via `verdaccio`. It will leave `verdaccio` running so you can use the server to test other aspects of your published package. When you're finished it will kill it.

> Can't I just use verdaccio?

Yeah you could, but you'd need to spin up verdaccio, open up another terminal most likely, login to the verdaccio registry, and then you'd have to type out the local url to publish your package. And if you've already published that version of your package, you then have to unpublish and republish it.

This does all of that in one command.

## Usage

### Installation

If you're using `pnpm` or working across multiple devices you'll want to install this package locally, otherwise, globally installing it makes no difference.

```bash
pnpm install --dev e2e-verdaccio

# or

yarn add --dev e2e-verdaccio
```

### Add it to your `scripts`

After installing the package you'll need to add it to your `scripts` for easy use.

```json
{
  "scripts": {
    "test:publish": "e2e-verdaccio"
  }
}
```

### Running it

Now to run it, simply run the `test:publish` script.

```bash
pnpm run test:publish

# or

yarn run test:publish
```

### Options

Here is a list of all of the CLI options

```
Usage: e2e-verdaccio [options]

Registry Login Options:
  -u  Value for the username. Default: test
  -p  Value for the password. Default: test
  -e  Value for the email. Default: test@test.com

Other Options:
  --port            The port for Verdaccio. Default: 4873
  --package-runner  The command to use for running npm packages. Defaults to pnpx when pnpm-lock.yaml exists, othwerwise, npx.
```
