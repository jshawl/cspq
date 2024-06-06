export const response = (status, headersList, body) => {
  let headers = new Headers();
  for (let [k, v] of headersList) headers.append(k, v);
  return new Response(body, {
    status,
    headers,
  });
};
