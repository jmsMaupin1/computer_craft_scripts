local inventory = {}

function inventory.get_free_spaces()
	local free_spaces = 0

	for _, item in turtle.list() do
		if not item then
			free_spaces = free_spaces + 1
		end
	end

	return free_spaces
end

function inventory.eject_blocks(rejection_list)
	for i = 1,16 do
		local item = turtle.getItemDetail(i)
		if item then
			for j = 1,#rejection_list do
				if string.find(item.name, rejection_list[i]) then
					turtle.select(i)
					turtle.drop()
				end
			end
		end
	end
end

function inventory.scan()
	print(turtle.list())
	print(#turtle.list())
end

function inventory.consolidate()
	
end

inventory.scan()
return inventory
