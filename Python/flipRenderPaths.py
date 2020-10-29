import os
import c4d
from c4d import documents

scene = documents.GetActiveDocument()
scenePath = scene.GetDocumentPath()
renderData = scene.GetActiveRenderData().GetData()

outputPath = renderData.GetFilename( c4d.RDATA_PATH )
outputPathMulti = renderData.GetFilename( c4d.RDATA_MULTIPASS_FILENAME )

def flipRenderPaths():
    os.chdir(scenePath)

    if os.path.isabs(outputPath):
        newPath = os.path.relpath(outputPath)
        newPathMulti = os.path.relpath(outputPathMulti)
    else:
        newPath = os.path.abspath(outputPath)
        newPathMulti = os.path.abspath(outputPathMulti)

    # push paths to cinema
    rDat = doc.GetActiveRenderData()
    rDat[c4d.RDATA_PATH] = newPath
    rDat[c4d.RDATA_MULTIPASS_FILENAME] = newPathMulti

    print(scenePath)

    # update cinema gui
    c4d.EventAdd()

flipRenderPaths()

# example paths
# C4D scenePath: U:\_TESTRENDER\Project
# Render Path - absolute: U:\_TESTRENDER\_Renders\Renders - C4D\$prj\$prj-
# Render Path - relative: ../_Renders/Renders - C4D/$prj/$prj-