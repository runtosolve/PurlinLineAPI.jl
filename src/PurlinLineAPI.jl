module PurlinLineAPI

using HTTP, Sockets, JSON3, PurlinLine, StructTypes

#define router
const ROUTER = HTTP.Router()

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

#add route 
HTTP.register!(ROUTER, "POST", "/api/purlin_line", request_response)


function run(;ip_address)

    server = HTTP.serve!(ROUTER, parse(IPAddr, ip_address), 8080)

    return server

end


end # module PurlinLineAPI
