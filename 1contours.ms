try(destroyDialog contourRol)catch()
rollout contourRol "Contour Generator" width:200
(
	local sourceObjs = #()
	fn pickFilt o = superclassof o == geometryClass and findItem sourceObjs o == 0
	
	groupBox sourceGB "Source Objects" pos:[5,5] width:190 height:135
	listBox sourceList "" pos:[10,23] width:180 height:6
	pickButton objPick "Pick" filter:pickFilt width:60 height:22 pos:[10,109]
	button objAdd "Add..." width:60 height:22 pos:[70,109]
	button objRem "Remove" width:60 height:22 pos:[130,109]
		
	groupBox axisGB "Slice Axis" width:190 height:35 pos:[5,140] 
	radioButtons axis "" labels:#("X    ","Y    ","Z") pos:[12,155]
	
	groupBox numGB "Amount" width:190 height:55 pos:[5,179]
	radioButtons segType "" labels:#("Total","Spacing") columns:1 pos:[12,195]
	spinner totalSpn "" type:#integer range:[1,1000,20] pos:[100,195] width:90
	spinner spacingSpn "" type:#worldUnits range:[0.001,1000000.0,1.0] enabled:off pos:[100,212] width:90
	
	groupBox splineOptions "Splines" width:190 height:109 pos:[5,235]
	checkBox weldChk "Weld Vertices" pos:[12,255] checked:on
	spinner weldSpn "" type:#worldUnits range:[0,1000000.0,0.01] pos:[100,255] width:90
	--checkBox normalizeChk "Normalize" pos:[12,298] checked:on
	--spinner normalizeSpn "" type:#float range:[1.0,1000000.0,2] pos:[100,298] width:90
	checkBox closeSpln "Close Splines" pos:[22,275]
	checkBox attachSpln "Collapse to Single Object" pos:[12,320] checked:on
	
	
	groupBox modifyGB "Spline Renderability" width:190 height:115 pos:[5,345]
	dropDownList outputDD "" items:#("Non-Renderable","Renderable (Radial)","Renderable (Rectangular)") width:180 pos:[10,363]
	
	spinner rendRadThickness "Thickness" type:#worldUnits range:[0.001,10000000.0,1.0] fieldwidth:70 pos:[30,390] visible:off
	spinner rendRadSides "Sides" type:#integer range:[3,100,12] fieldwidth:70 pos:[53,410] visible:off
	spinner rendRadAngle "Angle" type:#float range:[-10000000.0,10000000.0,0.0] fieldwidth:70 pos:[52,430] visible:off
	
	spinner rendRectLength "Length" type:#worldUnits range:[0.001,10000000.0,1.0] fieldwidth:70 pos:[46,390] visible:off
	spinner rendRectWidth "Width" type:#worldUnits range:[0.001,10000000.0,1.0] fieldwidth:70 pos:[51,410] visible:off
	spinner rendRectAngle "Angle" type:#float range:[-10000000.0,10000000.0,0.0] fieldwidth:70 pos:[52,430] visible:off
	
	button create "Generate Contours" enabled:off pos:[5,465] width:190 height:30
	
	fn setRenderability shap =
	(
		shap.render_renderable = shap.render_displayRenderMesh = outputDD.selection > 1
		if outputDD.selection == 2 then
		(
			shap.render_rectangular = off
			shap.render_thickness = rendRadThickness.value
			shap.render_sides = rendRadSides.value
			shap.render_angle = rendRadAngle.value
		)
		else
		(
			shap.render_rectangular = on
			shap.render_aspect_locked = off
			shap.render_length = rendRectLength.value
			shap.render_width = rendRectWidth.value
			shap.render_angle2 = rendRectAngle.value
		)
	)
	
	fn treeAttach objs =
	(
		for x = 1 to (ceil (pow objs.count 0.5)) do
		(
			for i = 1 to (objs.count/2) do
			(
				addAndWeld objs[i] objs[i+1] 0.0
				deleteItem objs (i+1)
			)
		)
		objs[1]
	)
	
	on objPick picked o do if isValidNode o do 
	(
		append sourceObjs o
		sourceList.items = append sourceList.items o.name
		create.enabled=on
	)
	
	on objAdd pressed do
	(
		local newObjs = (selectByName title:"Select source objects" filter:pickFilt)
		if newObjs!=undefined do
		(
			sourceObjs+=newObjs
			sourceList.items+=for n in newObjs collect n.name
		)
		create.enabled=sourceObjs.count>0
	)
	
	on objRem pressed do
	(
		if sourceList.selection > 0 do 
		(
			deleteItem sourceObjs sourceList.selection
			sourceList.items = deleteItem sourceList.items sourceList.selection			
		)
		create.enabled=sourceObjs.count>0
	)
	
	on segType changed state do 
	(
		totalSpn.enabled = state==1
		spacingSpn.enabled = state==2
	)
	
	on weldChk changed state do
	(
		weldSpn.enabled = closeSpln.enabled = state
	)
	--on normalizeChk changed state do normalizeSpn.enabled = state
	
	on outputDD selected arg do
	(
		for c in contourRol.controls where matchPattern c.name pattern:"rendRad*" do c.visible = outputDD.selection==2
		for c in contourRol.controls where matchPattern c.name pattern:"rendRect*" do c.visible = outputDD.selection==3
	)
	
	on create pressed do
	(
		local badObjs = for o in sourceObjs where not isValidNode o collect 1
		if badObjs.count>0 do return (messageBox (badObjs.count as string+" invalid or deleted objects."))
		for o in sourceObjs where o.isHiddenInVpt do unhide o
		local otherObjs = for o in objects where not o.isHiddenInVpt  and findItem sourceObjs o == 0 collect o
		hide otherObjs
		select sourceObjs
		local minP = case axis.state of
		(
			1:(selection.min.x)
			2:(selection.min.y)
			3:(selection.min.z)
		)
		local maxP = case axis.state of
		(
			1:(selection.max.x)
			2:(selection.max.y)
			3:(selection.max.z)
		)
		local delta = if segType.state==1 then (maxP - minP) / (totalSpn.value) else spacingSpn.value
		local total = if segType.state==1 then totalSpn.value else (((maxP-minP)/spacingSpn.value) as integer)
		local sRotation = case axis.state of
		(
			1:(quat 0 -0.707107 0 0.707107)
			2:(quat -0.5 -0.5 -0.5 0.5)
			3:(quat 0 0 0 1)
		)
		progressStart ("Generating "+total as string+" contours.")
		local count = 0
		local singleShape
		local contourShapes=#()
		--local normalizeMod = Normalize_Spline length:(normalizeSpn.value)
		for currentP = minP to maxP by delta do
		(			
			local p3 = case axis.state of
			(
				1:([currentP,0,0])
				2:([0,currentP,0])
				3:([0,0,currentP])				
			)
			local s = section rotation:sRotation name:(uniqueName "Contour")
			s.pos = p3
			redrawViews()
			convertToSplineShape s
			if weldChk.checked do
			(
				for spl = 1 to s.numSplines do
				(
					setKnotSelection s spl (for k = 1 to (numKnots s spl) collect k)
				)
				weldSpline s 0.001
				weldSpline s weldSpn.value
				updateShape s
				for spl = 1 to s.numSplines do
				(
					for k = 1 to (numKnots s spl) do setKnotType s spl k #corner
				)
			)
			if weldChk.checked and closeSpln.checked do
			(
				for spl = 1 to s.numSplines do close s spl
				updateShape s
			)
			/*if normalizeChk.checked do
			(
				addModifier s normalizeMod
				convertToSplineShape s
			)
			*/
			if not attachSpln.checked then setRenderability s else s.render_displayRenderMesh=off
			append contourShapes s
			count+=1			
			progressUpdate ((count as float/total)*100)
			if (getProgressCancel()) do exit
		)
		if attachSpln.checked then
		(
			local single = (treeAttach contourShapes)
			setRenderability single
			select single
			single.name = uniqueName "Contour"
		)
		else select contourShapes
		unhide otherObjs
		progressEnd()
	)
)
createDialog contourRol