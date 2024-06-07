export const response = (status, headersList, body) => {
  let headers = new Headers();
  for (let [k, v] of headersList) headers.append(k, v);
  return new Response(body, {
    status,
    headers,
  });
};

export const url = (request) => request.url;

export const listen = () =>
  globalThis.addEventListener("message", (e) => {
    console.log("received message", e.data);
  });
