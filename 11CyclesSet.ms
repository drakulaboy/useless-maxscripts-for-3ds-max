if (( mainRoll != undefined) and ( mainRoll.isdisplayed)) do
(destroyDialog mainRoll ) 

fn checkRender nSearch = 
(
	theRenderer = for obj in RendererClass.classes where \
	  (matchPattern (obj as string) pattern:nSearch)
		collect  obj
		if theRenderer.count ==1
		   then  renderers.current = theRenderer[1]()
 else  
		 (messageBox "Render not  installed")

	
)	

rollout mainRoll  "Set Cycles"
(
	group "Change Render"
	(
	 button butSet "Cycles" align:#left across:2 width:70 height:20
	 button butCUDAH "CUDA High" align:#left width:70 height:20
	 button cudaWithCPU "cudaWithCPU" align:#left across:2 width:70 height:20
	 button butCUDAL "CUDA Low" align:#left  across:2 width:70 height:20
	 button butLoRes "640x480" align:#left  across:2 width:70 height:20
	 button butHiRes "1920x1080" align:#left  across:2 width:70 height:20
	 button butAddSky "Cycles Sky" align:#left  across:2 width:70 height:20
	 button butAddPhysSky "Physical Sky" align:#left  across:2 width:70 height:20
	)	
	
		
	on butSet pressed do 
(
	varScan = "*Cycles*"
	checkRender varScan
	)
	
	on butCUDAH pressed do 
(
cyclesRender.renderDevice = 1
cyclesRender.samples = 250
cyclesRender.sampleClampIndirect = 1.8
cyclesRender.tileWidth = 512
cyclesRender.tileHeight = 512
	)
	
	on butCUDAL pressed do 
(
cyclesRender.renderDevice = 1
cyclesRender.samples = 10
cyclesRender.sampleClampIndirect = 1.8
cyclesRender.tileWidth = 512
cyclesRender.tileHeight = 512	
	)

	on cudaWithCPU pressed do 
(
cyclesRender.cudaWithCPU=1
	)
	
	on butLoRes pressed do 
(
	renderWidth=640
	renderHeight=480
	)
	
		on butHiRes pressed do 
(
	renderWidth=1920
	renderHeight=1080
	)

		on butAddSky pressed do 
(
	useEnvironmentMap = true
	environmentMap = Cycles_sky ()
	environmentMap.sky_type = 1
	)
	
		on butAddPhysSky pressed do 
(
	useEnvironmentMap = true
	environmentMap = Physical_Sun___Sky_Environment ()
	SceneExposureControl.exposurecontrol = automatic_exposure_control()
	)
	
)

createDialog  mainRoll  175  140