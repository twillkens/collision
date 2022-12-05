export get_config

"convert Dict to named tuple"
function get_config(cfg::Dict)
    (; (Symbol(k)=>v for (k, v) in cfg)...)
end

"combine YAML file and kwargs, make sure ID is specified"
function get_config(cfg_file::String; kwargs...)
    cfg = YAML.load_file(cfg_file)
    for (k, v) in kwargs
        cfg[String(k)] = v
    end
    # generate id, use date if no existing id
    if ~(:id in keys(cfg)) && ~("id" in keys(cfg))
        cfg["id"] = string(Dates.now())
    end
    get_config(cfg)
end
