module Handler = struct
  type t = Request.t -> Response.t
end

module Middleware = struct
  type t = Handler.t -> Handler.t
end
