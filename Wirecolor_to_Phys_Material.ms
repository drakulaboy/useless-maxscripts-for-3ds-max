for i in selection do
(
	if i.material==undefined then
	(
		thecolor=i.wirecolor
		themat=Physical_Material()
		themat.name=i.name
		themat.Base_Color=thecolor		
		i.material=themat
	)
)