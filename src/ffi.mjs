export const getHash = () => globalThis.location?.hash ?? "";

export const setHash = (value) => {
  if (globalThis.location) {
    globalThis.location.hash = value;
  }
};
