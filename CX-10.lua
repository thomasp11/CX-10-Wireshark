-- CX-10DS Drone Protocol Lua Dissector
-- Roll, Pitch, Throttle, Yaw, Command
-- declare our protocol
cx10ds_proto = Proto("cx-10ds","CX-10DS Drone Protocol")
cx10ds_proto.fields.roll = ProtoField.new ("Roll", "cs10ds.roll", ftypes.UINT8)
cx10ds_proto.fields.pitch = ProtoField.new ("Pitch", "cs10ds.pitch", ftypes.UINT8)
cx10ds_proto.fields.throttle = ProtoField.new ("Throttle", "cs10ds.throttle", ftypes.UINT8)
cx10ds_proto.fields.yaw = ProtoField.new ("Yaw", "cs10ds.yaw", ftypes.UINT8)
cx10ds_proto.fields.command = ProtoField.new ("Command", "cs10ds.command", ftypes.STRING)
cx10ds_proto.fields.checksum = ProtoField.new ("Checksum", "cs10ds.checksum", ftypes.UINT8)

-- create a function to dissect it
function cx10ds_proto.dissector(buffer,pinfo,tree)
    --local pf_roll = ProtoField.new ("Roll", "cs10ds.roll", ftypes.UINT8)

    pinfo.cols.protocol = "CX-10DS Drone Protocol"
    local subtree = tree:add(cx10ds_proto,buffer(),"CX-10DS Drone Protocol Data")

    subtree:add(cx10ds_proto.fields.roll, buffer(1,1))
    subtree:add(cx10ds_proto.fields.pitch, buffer(2,1))
    subtree:add(cx10ds_proto.fields.throttle, buffer(3,1))
    subtree:add(cx10ds_proto.fields.yaw, buffer(4,1))
    local cmd_val = buffer(5,1):uint()
    local cmd_string = ""
    if cmd_val == 1 then
      cmd_string = "takeoff"
    elseif cmd_val == 2 then
      cmd_string = "land"
    elseif cmd_val == 64 then
      cmd_string = "flip"
    elseif cmd_val == 128 then
      cmd_string = "calibrate"
    else
      cmd_string = "none"
    end
    subtree:add(cx10ds_proto.fields.command, cmd_string)
    subtree:add(cx10ds_proto.fields.checksum, buffer(6,1))
end
-- load the udp.port table
udp_table = DissectorTable.get("udp.port")
-- register our protocol to handle udp port 8033
udp_table:add(8033,cx10ds_proto)
