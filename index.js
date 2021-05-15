const main = process.platform === 'darwin' ? require('bindings')('main.node') : undefined;

const getIcon = async (input, output, size) => {
  if (process.platform !== 'darwin') {
    throw new Error('node-mac-file-icon only works on macOS')
  }

  return new Promise((resolve, reject) => {
    main.getFileIcon(input, output, size, (result) => {

      resolve(result);
    });
  })
};

module.exports = {
  getIcon,
};
