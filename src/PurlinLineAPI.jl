module PurlinLineAPI

using HTTP, Sockets, JSON3, PurlinLine, StructTypes

#define router
const ROUTER = HTTP.Router()

# CORS preflight headers that show what kinds of complex requests are allowed to API
const CORS_OPT_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]

# CORS response headers that set access right of the recepient
const CORS_RES_HEADERS = ["Access-Control-Allow-Origin" => "*"]

#define server request and response function
StructTypes.StructType(::Type{PurlinLine.Inputs}) = StructTypes.Struct()

#receive PurlinLine inputs from client, run pkg, return results to client
function request_response(req::HTTP.Request)
 
    inputs = JSON3.read(req.body, PurlinLine.Inputs)

    model = PurlinLine.build(inputs)

    model = PurlinLine.test(model)

    model_json = JSON3.write(model)

    HTTP.Response(200, model_json)

end

function CorsMiddleware(handler)
    return function(req::HTTP.Request)
        if HTTP.hasheader(req, "OPTIONS")
            return HTTP.Response(200, CORS_OPT_HEADERS)
        else 
            return handler(req)
        end
    end
end


#add route 
HTTP.register!(ROUTER, "POST", "/api/purlin_line", request_response)

# CORS handlers for error responses
cors404(::HTTP.Request) = HTTP.Response(404, CORS_RES_HEADERS, "")
cors405(::HTTP.Request) = HTTP.Response(405, CORS_RES_HEADERS, "")


function run(;ip_address)

    server = HTTP.serve!(ROUTER |> CorsMiddleware, parse(IPAddr, ip_address), 8080)

    return server

end


end # module PurlinLineAPI


