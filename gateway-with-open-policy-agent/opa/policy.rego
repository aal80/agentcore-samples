package pizzashop

# Deny by default
default allowed_to_get_menu = false
default allowed_to_create_orders = false

allowed_to_get_menu if {
    scopes := split(input.scope, " ")
    "gateway/get_menu" in scopes
}

allowed_to_create_orders if {
    scopes := split(input.scope, " ")
    "gateway/create_order" in scopes
    
    # NO PINEAPPLE PIZZA!
    input.mcpToolArguments.pizzaId != 5 
}
