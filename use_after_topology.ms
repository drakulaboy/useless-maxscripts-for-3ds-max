(
modPanel.addModToSelection (Vol__Select()) ui:on
$.modifiers[#Vol__Select].level = 2
modPanel.addModToSelection(Edit_Poly()) ui:on
subObjectLevel = 4
$.modifiers[#Edit_Poly].animationMode = 1
$.modifiers[#Edit_Poly].SetOperation #Inset
$.modifiers[#Edit_Poly].insetType = 1
$.modifiers[#Edit_Poly].insetAmount = 1.9685
modPanel.addModToSelection(Poly_Select()) ui:on
subObjectLevel = 4
modPanel.addModToSelection(DeleteMesh()) ui:on
modPanel.addModToSelection(Shell()) ui:on
$.modifiers[#Shell].outerAmount = 1.68
$.modifiers[#Shell].innerAmount = 0
$.modifiers[#Shell].outerAmount = 1.9685
modPanel.addModToSelection(meshsmooth()) ui:on
$.modifiers[#MeshSmooth].subdivMethod = 0
$.modifiers[#MeshSmooth].iterations = 3
clearSelection()
actionMan.executeAction 0 "369" 
)