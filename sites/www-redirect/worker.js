// www.mightyagents.dev → mightyagents.dev, keeping the path and query.
export default {
  fetch(request) {
    const url = new URL(request.url);
    url.hostname = "mightyagents.dev";
    return Response.redirect(url.toString(), 301);
  },
};
