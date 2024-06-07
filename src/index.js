import { handle_request } from "./server.mjs";

export default {
  async fetch(request) {
    return handle_request(request);
  },
};
