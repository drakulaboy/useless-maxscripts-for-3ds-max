dummyObj = Dummy name:"CPU_Name" boxsize:[5,5,5] position:[0,150,0]--create your dummy

Fn  GetHardwareInfo HwClass HwProp  =
(
    local HwInfo,HwInfoEnumerator,OutArray
    OutArray = #()
    try
    (
        HwInfo = (DotNetObject "System.Management.ManagementClass" HwClass).GetInstances()
    )
    catch
    (
        DotNet.LoadAssembly  "System.Management.dll"
        HwInfo = (DotNetObject "System.Management.ManagementClass" HwClass).GetInstances()
    )
    HwInfoEnumerator = HwInfo.GetEnumerator()
    while (HwInfoEnumerator.MoveNext())  do
    (
        local TempString =  HwInfoEnumerator.Current.Item[HwProp] as string
        if TempString != "" do append OutArray TempString
    )
    OutArray
)

Fn GetHardwareClassInfo HwClass =
(
    local HwInfo,HwInfoEnumerator,OutArray
    OutArray = #()
    try
    (
        HwInfo = (DotNetObject "System.Management.ManagementClass" HwClass).GetInstances()
    )
    catch
    (
        DotNet.LoadAssembly  "System.Management.dll"
        HwInfo = (DotNetObject "System.Management.ManagementClass" HwClass).GetInstances()
    )
  
    HwInfoEnumerator = HwInfo.GetEnumerator()
    while (HwInfoEnumerator.MoveNext())  do
    (
        PropEnumerator = HwInfoEnumerator.Current.Properties.GetEnumerator()
        while (PropEnumerator.MoveNext()) do
            (
                local TempString = PropEnumerator.Current.Name as string
                if TempString != "" do append OutArray TempString
            )
    )
    OutArray
)

GetHardwareClassInfo "Win32_Processor"
GetHardwareClassInfo "Win32_VideoController"

--GetHardwareInfo "Win32_Processor"  "Name"
--GetHardwareInfo "Win32_VideoController" "Name"

fn label_it obj = (
    cpu_info = (GetHardwareInfo "Win32_Processor" "Name")
    t = TextPlus size:20
    t.SetFont "Arial" 0
    t.ResetStyle()
    t.ResetString()
    t.AppendString cpu_info[1]
    t.pos = obj.pos
    bb = nodeLocalBoundingBox obj
    t.pos.z = bb[2].z
    t.parent = obj   -- link label to object
        t.extrudeamount = 2
)

myObj = $CPU_Name
for obj in myObj do (
    
    -- don't label textplus objects, that would be silly
    if (classOf obj == Dummy) do (

        label_it obj
    )
)


dummyObj = Dummy name:"CPU_Cores" boxsize:[5,5,5] position:[0,130,0]
fn label_it obj = (
    nrCores = sysinfo.cpucount  as string
    textCore = "Your system has "+nrCores+"% CPUs (Cores)\n"
    t = TextPlus size:20
    t.SetFont "Arial" 0
    t.ResetStyle()
    t.ResetString()
    t.AppendString textCore
    t.pos = obj.pos
    bb = nodeLocalBoundingBox obj
    t.pos.z = bb[2].z
    t.parent = obj   -- link label to object
        t.extrudeamount = 2
)

myObj = $CPU_Cores
for obj in myObj do (
    
    -- don't label textplus objects, that would be silly
    if (classOf obj == Dummy) do (

        label_it obj
    )
)

dummyObj = Dummy name:"GPU_Name" boxsize:[5,5,5] position:[0,110,0] --create your dummy

fn ManagementObjectSearcherAssembly =
(
    source  = ""
    source += "using System;
"
    source += "using System.Management;
"
    source += "using System.Collections.Generic;
"
    source += "namespace ManagementObjectSearcherOps
"
    source += "{
"
    source += "    class Video
"
    source += "    {
"
    source += "        public Object[] GetVideoControllers()
"
    source += "        {
"
    source += "            List<Object> props = new List<Object>();
"
    source += "            ManagementObjectSearcher searcher = new ManagementObjectSearcher(\"SELECT * FROM Win32_VideoController\");
"
    source += "            foreach (ManagementObject obj in searcher.Get())
"
    source += "            {
"
    source += "                PropertyData currentBitsPerPixel = obj.Properties[\"CurrentBitsPerPixel\"]; //check for valid Graph Card Controller
"
    source += "                PropertyData description = obj.Properties[\"Description\"];
"
    source += "                if (currentBitsPerPixel != null && description != null)
"
    source += "                {
"
    source += "                    if (currentBitsPerPixel.Value != null) props.Add(description.Value);
"
    source += "                }
"
    source += "            }
"
    source += "            return props.ToArray();
"
    source += "        }
"
    source += "    }
"
    source += "}
"

    csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
    compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

    compilerParams.ReferencedAssemblies.AddRange #("System.dll", "System.Management.dll")

    compilerParams.GenerateInMemory = on
    compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
    
    assembly = compilerResults.CompiledAssembly
    assembly.CreateInstance "ManagementObjectSearcherOps.Video"
)
global ManagementVideo = ManagementObjectSearcherAssembly()
vc = ManagementVideo.GetVideoControllers()



fn label_it obj = (
    gpu_name = ManagementVideo.GetVideoControllers()
    t = TextPlus size:20
    t.SetFont "Arial" 0
    t.ResetStyle()
    t.ResetString()
    t.AppendString gpu_name[1]
    t.pos = obj.pos
    bb = nodeLocalBoundingBox obj
    t.pos.z = bb[2].z
    t.parent = obj   -- link label to object
        t.extrudeamount = 2
)

myObj = $GPU_Name
for obj in myObj do (
    
    -- don't label textplus objects, that would be silly
    if (classOf obj == Dummy) do (

        label_it obj
    )
)