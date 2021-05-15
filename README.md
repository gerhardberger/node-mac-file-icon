# Node macOS Icon fetcher

## Installation

Using Yarn
```sh
yarn add node-mac-file-icon
```

Using NPM

```sh
npm install node-mac-file-icon
```

## Usage with Electron

Add to main process

```js
import { getIcon } from 'node-mac-file-icon';

await getIcon('/Applications/Pages.app', './pages.png', 240)
```

## License

The package is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
