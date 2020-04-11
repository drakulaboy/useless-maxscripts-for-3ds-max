clearlistener()
dummyObj = Dummy boxsize:[5,5,5] --create your dummy
fn label_it obj = (

	start = timeStamp()
	sliderTime = 100 -- jumping to frame 100
	end = timeStamp()
	all_time = ((end - start) / 1000.0) as string
	t = TextPlus size:20
	t.SetFont "Arial" 0
	t.ResetStyle()
	t.ResetString()
	procTime = "Processing took "+all_time+"% seconds\n"
	t.AppendString procTime
	t.pos = obj.pos
	bb = nodeLocalBoundingBox obj
	t.pos.z = bb[2].z
	t.parent = obj   -- link label to object
        t.extrudeamount = 2
)

myObj = $Dummy001
for obj in myObj do (
	
	-- don't label textplus objects, that would be silly
	if (classOf obj == Dummy) do (

		label_it obj
	)
)