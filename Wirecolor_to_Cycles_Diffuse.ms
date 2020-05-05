for i in selection do
(
	if i.material==undefined then
	(
		thecolor=i.wirecolor
		themat=Cycles_Diffuse__Surface()
		themat.name=i.name
		themat.color=thecolor		
		i.material=themat
	)
)