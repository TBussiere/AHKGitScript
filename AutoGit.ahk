;==============TODO==============
;
; - Auto Update
; - Enable Edit already generated
; - Direct Edit Reten
;
;===============================

#Requires AutoHotkey v2.0

global Version := "v0.9"


global OutReten := ""
global pathToReten := ""
global gitCommand := "git status --porcelain"
global gitCommand_ForOldCommits := "git show --oneline --name-status {1}"

global ToClip := true

global combo_res := ""

global git_StageStruct := Map()



^+F9::
{
    pathToReten := PathWindow()

    if(pathToReten == ""){
        return
    }

    SetWorkingDir pathToReten

    

}




/*


^+F9::
{
    ;IN
    tosearch := "1.1.8.1. DCR01"
    seekTitleRank := 4
    toAdd := Map()
    
    aze := []
    aze.Push("DCR01.boo")
    aze.Push("aze.boo")
    aze.Push("ImportDCR01.boo")
    aze.Push("ggg.boo")
    toAdd.Set("boo", aze)
    
    if(seekTitleRank == 3 and not toAdd.Has("Mono")){
        ToolTip "Error"
        SetTimer () => ToolTip(), -1000
        return
    }

    ;Get Path
    pathToReten := PathWindow()

    if(pathToReten == ""){
        return
    }

    SetWorkingDir pathToReten

    ;Get Reten
    retenpath := "\doc\support\" ;*.md"
    GetMDFile( Format("{1}{2}", String(A_WorkingDir), retenpath)) ;"FR-SW-0420_PROJECT_Code_Documentation_EN.md"
    filename := RetenFileName
    full_path := Format("{1}{2}{3}", String(A_WorkingDir), retenpath, filename)

    

    /*o_file := FileOpen(full_path, "rw")

    fullfile := o_file.Read()
    fullfileTab := StrSplit(fullfile, "`n", "")



    
    found := false

    i:=0
    line:=""
    while (i<65534 and not InStr(line, "## **1.2"))
    {
        i := i + 1
        line := fullfileTab[i]
        If(RegExMatch(line,"^\#\#\# \*\*1\.") != 0 and seekTitleRank == 3) {
            if(InStr(line,tosearch)) {
                found := true
                
            }
            else if(found){
                found := false
                break
            }
        }
        else if(RegExMatch(line,"^\#\#\#\# \*\*1\.") != 0 and seekTitleRank == 4) {
            if(InStr(line,tosearch)){
                found := true
                
            }
            else if(found){
                found := false
                break
            }
        }
        if(found){
            if(seekTitleRank == 4 and RegExMatch(line,"^\#\#\#\#\# \*\*1\..*Technical implementation") != 0){
                ToolTip Format("aze : {1}", line)
                SetTimer () => ToolTip(), -3000
                break
            }
            else if(RegExMatch(line,"^\#\#\#\#\# \*\*1\..*Custom elements") != 0){
                ToolTip Format("aze : {1}", line)
                SetTimer () => ToolTip(), -3000
            }

        }
        
    }


    if(seekTitleRank == 4){
        Current := ""
        list := []
        ToolTip "==LOOP DEBUG=="
        Sleep 1000
        i := i+1
        Loop {
            ToolTip fullfileTab[i]
            Sleep 1000
            ToolTip()
            if(RegExMatch(fullfileTab[i], "^\*\*(.*)\*\* :", &match) != 0) {
                if((not Current == "") and (list.Length > 0)) {
                    ToolTip "PASS in apply"
                    Sleep 1000
                    i := i-1
                    for(l in list) {
                        ToolTip Format("add : {1}",l)
                        Sleep 1000
                        fullfileTab.InsertAt(i, l)
                        i := i+1
                    }
                    i := i+1
                }
                Current := match[1]
                if(toAdd.Has(Current)) {
                    list := toAdd[Current]
                }
                else{
                    Current := ""
                }
            }
            else{
                if(RegExMatch(fullfileTab[i], "- \*\*(.*)\*\* :", &match) != 0) {
                    ind := list.Has(match[1])
                    if(ind != 0) {
                        list.RemoveAt(ind)
                    }
                }
            }


            if(RegExMatch(fullfileTab[i], "^\#\#\#\#\# \*\*1\..*Custom elements", &match) != 0){
                break
            }
            i := i +1
        }
         
        ToolTip i
        Sleep 3000
        ToolTip()

    }
    else if(seekTitleRank == 3){
        i := i-2
        fullfileTab.InsertAt(i, toAdd.Get("Mono")[1])
    }
    else{
        ToolTip "Not Implemented"
        SetTimer () => ToolTip(), -1000
        return
    }
    ;fullfileTab.InsertAt(i-2, "===TEST===")

    if(ToClip){
        A_Clipboard := GetTaskStr(fullfileTab, i)
    }
    else{
        fullfile := tofullstr(fullfileTab)
        ;FileDelete(full_path)
        ;FileAppend(fullfile,full_path)
    }
 
    ToolTip A_Clipboard
    SetTimer () => ToolTip(), -1000

}
*/

tofullstr(tab){
    res := ""
    for line in tab{
        res := Format("{1}{2}", res, line)
    }
    return res
}

GetTaskStr(tab, index) {
    lineMatch := ""

    Loop {
        if(RegExMatch(tab[index], "^\#\#\#\# \*\*1\.")) {
            break
        }
        index := index -1
    }

    res := ""
    Loop {
        res := Format("{1}{2}", res, tab[index])
        index:= index +1 
        if(RegExMatch(tab[index], "^\#\#\#\# \*\*1\.")) {
            break
        }
    }

    return res
    
}


;main function
; CTRL+SHIFT+F8
^+F8::
{
    ;Get Path
    pathToReten := PathWindow()

    if(pathToReten == ""){
        return
    }

    SetWorkingDir pathToReten

    gitStatus := RunWaitOne(gitCommand)

    gitStatus_list := StrSplit(gitStatus, "`n", "")

    ;Parse GIT status
    stagedFiles := []
    stopdupli := Map()
    
    for line in gitStatus_list
    {

        If (RegExMatch(line,"^[^ ] *(.*)", &t)==0)
        {
            continue
        }
        t := t[1]
        
        ;ToolTip Format("out : {1}", test[1])d
        ;SetTimer () => ToolTip(), -5000
        If (InStr(t,"EasyB") and InStr(t,"source")){
            SplitPath t, &name, &dir, &ext, &name_no_ext, &drive
            res := StrSplit(name, ".", "")[1]
            If(NOT stopdupli.Has(res))
            {
                stopdupli[res] := res
            }
        }
        else if(InStr(t,"GNA") and InStr(t,"source")){
            SplitPath t, &name, &dir, &ext, &name_no_ext, &drive
            res := name
            If(NOT stopdupli.Has(res))
            {
                stopdupli[res] := res
            }
        }
    }

    for a, b in stopdupli{
        stagedFiles.Push(a)
    }
    

    ;Organize GIT status
    BuildValues(stagedFiles)


    /* DEBUG
    for _filetype, _list in git_StageStruct{

        ToolTip Format("TYPE: {1}", _filetype)
        Sleep 1000

        for _file in _list{
            ToolTip Format("File: {1}", _file)
            Sleep 1000
        }
        ToolTip()
    }
    */
    
    



    ;Get Reten
    retenpath := "\doc\support\" ;*.md"
    GetMDFile( Format("{1}{2}", String(A_WorkingDir), retenpath)) ;"FR-SW-0420_PROJECT_Code_Documentation_EN.md"
    filename := RetenFileName
    full_path := Format("{1}{2}{3}", String(A_WorkingDir), retenpath, filename)
    
    o_file := FileOpen(full_path, "r")

    Titles := []
    Task := []
    last_title := ""
    last_task := Map()
    
    ;Parse Reten
    i := 0
    line := ""
    while (i<65534 and not InStr(line, "## **1.2"))
    {
        i := i + 1
        line := o_file.ReadLine()
        If(RegExMatch(line,"^\#\#\# \*\*1\.") != 0)
        {
            Titles.Push(line)
            last_title := line
        }
        else if(RegExMatch(line,"^\#\#\#\# \*\*1\.") != 0){
            last_task[last_title] := line
            Task.Push(line)
        }
    }

    ;Build Combobox GUI
    MyGui := Gui()

    comboBox := MyGui.Add("ComboBox", "W267 vCategorie", Titles)
    
    global old_Commit := MyGui.Add("CheckBox", "vOldCommit", "A partir d'un vieux commit ..")

    global old_Commit_Label := MyGui.Add("Text","Section Hidden", "SHA:")
    global old_Commit_input := MyGui.Add("Edit", "ys r1 W175 vMyEdit Hidden", "")
    MyBtn := MyGui.Add("Button", "Default w175", "OK")
    global old_Commit_btn := MyGui.Add("Button","ys Hidden","Update")
    ;global old_Commit_comboBox := MyGui.Add("ComboBox", "W200 vTask Hidden", Task)


    
    
    MyBtn.OnEvent("Click", MyBtn_Click)
    comboBox.OnEvent("Change", combo_Change)
    old_Commit.OnEvent("Click", oldCommit_Change)
    old_Commit_btn.OnEvent("Click", oldCommit_update)

    CoordMode "Mouse", "Screen"
    MouseGetPos &OutputVarX, &OutputVarY

    MyGui.Show

    MyGui.Move(OutputVarX, OutputVarY, 300, 150)
    

    MyBtn_Click(GuiCtrlObj, info)
    {
        ;if edit
        /*If(old_Commit.Value == 1){
            ToolTip "Not Implemented"
            SetTimer () => ToolTip(), -1000
            return


        }*/
        ;If Good user choice 
        If(combo_res != ""){
            GuiCtrlObj.Gui.Destroy()

            ;Build final Reten text
            ;last_task[combo_res]

            result := "#### **1.1.{1}.{2}. [TITLE]**`n`n##### **1.1.{1}.{2}.1. Functional description**`n[DESCRIPTION]`n`n##### **1.1.{1}.{2}.2. Technical implementation**`n{3}`n`n##### **1.1.{1}.{2}.3. Custom elements**`n|**Type**|**Name**|**Observations**|`n| :- | :- | :- |`n{4}`n" 
            
            Text_Technical_imp := GetText_Technical_imp()
            Text_Custom_elements := GetText_Custom_elements()

            if(last_task.Has(combo_res)){
                if(RegExMatch(last_task[combo_res], "^\#\#\#\#.*1\.1\.([0-9]*)\.([0-9]*)", &lineMatch)){
                    index1 := lineMatch[1]
                    index2 := Integer(lineMatch[2])+1
                }
                else if(RegExMatch(last_task[combo_res], "^\#\#\#\#.*1\.1\.([0-9]*)\.([0-9]*)\.", &lineMatch)) {
                    index1 := lineMatch[1]
                    index2 := Integer(lineMatch[2])+1
                }
                else {
                    index1 := "?"
                    index2 := "?"
                }
            }
            else{
                RegExMatch(combo_res, "^\#\#\#.*1\.1\.([0-9]*)\.", &lineMatch)
                index1 := lineMatch[1]
                index2 := 1
            }

            

            final_result := Format(result, index1, index2, Text_Technical_imp, Text_Custom_elements)

            ToolTip final_result
            ;ToolTip Format("aze : {1}", last_task[combo_res])
            SetTimer () => ToolTip(), -5000

            A_Clipboard := final_result


        }
        else{
            ToolTip "Selectionez une categorie .."
            SetTimer () => ToolTip(), -1000
        }
    }

    GetText_Technical_imp(){
        lineformat := "- **{1}** : [...] `n"

        result := ""
        
        for _filetype, _list in git_StageStruct{
            result := Format("{1}`n**{2}** :`n", result, _filetype)

            for _file in _list{
                line := Format(lineformat, _file)

                result := Format("{1}{2}",result, line)
            }
        }

        return result
    }

    GetText_Custom_elements(){
        lineformat := "|{1}|{2}||`n"
        result := ""
        
        for _filetype, _list in git_StageStruct{
            for _file in _list{
                line := Format(lineformat, _filetype, _file)

                result := Format("{1}{2}",result, line)
            }
        }

        return result
    }

    combo_Change(GuiCtrlObj, info)
    {
        global combo_res := GuiCtrlObj.Text
    }

    oldCommit_Change(GuiCtrlObj, info){
        
        if(GuiCtrlObj.Value == 1){
            old_Commit_input.Visible := true
            old_Commit_Label.Visible := true
            old_Commit_btn.Visible := true
            ;old_Commit_comboBox.Visible := true
        }
        else{
            old_Commit_input.Visible := false
            old_Commit_Label.Visible := false
            old_Commit_btn.Visible := false
            UpdateCommitList("")
            ;old_Commit_comboBox.Visible := false
        }
        
        
    }
    oldCommit_update(GuiCtrlObj, info){
        UpdateCommitList(old_Commit_input.Value)
    }

}


CreateWindowPrompt(Prompt, BaseValue := "", title := "Prompt")
{
    CoordMode "Mouse", "Screen"
    MouseGetPos &OutputVarX, &OutputVarY
    str := Format("X{1} Y{2} w100 h100", OutputVarX, OutputVarY)
    return InputBox(Prompt, title, str, BaseValue).value
}

PathWindow()
{
    CoordMode "Mouse", "Screen"
    MouseGetPos &OutputVarX, &OutputVarY
    return FileSelect("D1", pathToReten, "Choisir le reten")
}


RunWaitOne(command) {
    tempFile := A_Temp "\output.txt"

    RunWait(A_ComSpec " /C " command " > " "`"" tempFile "`"", , "Hide")

    output := FileRead(tempFile)
    FileDelete(tempFile)
    return output
}

_oldRunWaitOne(command) {
    shell := ComObject("WScript.Shell")
    exec := shell.Exec(A_ComSpec " /C " command)
    return exec.StdOut.ReadAll()
}

BuildValues(stagedLines := []){
    /*if(stagedLines.Length == 0){
        MsgBox Format("out : vide, Vous devez Git add les element a prendre en compte dans le reten"), "Erreur", 48
        ToolTip()
        Exit -1
    }*/

    result := Map()

    for line in stagedLines{
        ;source/(cstapp or GNA)/(TypeModif/subdir)/(Value/sudir/garbage)
        match := RegExMatch(line, "^\t?source\/(.*)\/(.*)\/(.*)$", &lineMatch)
        if(match == 0){
            continue
        }

        if(InStr(lineMatch[1],"GNA")) {
            SplitPath line, &name, &dir, &ext, &name_no_ext, &drive
            if(not result.Has(ext)){
                result[ext] := []
            }
            str := StrSplit(name, '/')

            result[ext].Push(str[str.Length])
        }
        else{
            if(not result.Has(lineMatch[2])){
                result[lineMatch[2]] := [] 
            }

            result[lineMatch[2]].Push(lineMatch[3])
        }
    }

    global git_StageStruct := result
}


global RetenFileName := "FR-SW-0420_PROJECT_Code_Documentation_EN.md"
GetMDFile(path){
    
    dirPath := path

    mdFiles := []

    Loop Files dirPath "\*.md", "F"
    {
        ; Exclude readme.md (case-insensitive)
        if (StrLower(A_LoopFileName) != "readme.md")
        {
            mdFiles.Push(A_LoopFileName)
        }
    }

    if(mdFiles.Length == 1){
        global RetenFileName := mdFiles.Pop()
    }
    else{
        ToolTip "Multiple MD files"
        SetTimer () => ToolTip(), -5000
        Exit -1
    }

}


GetOldCommit(in_SHA, Head := false){
    gitStatus := ""
    if(Head){
        gitStatus := RunWaitOne(gitCommand)
    }
    else{
        gitStatus := RunWaitOne(Format(gitCommand_ForOldCommits, in_SHA))
    }
    

    gitStatus_list := StrSplit(gitStatus, "`n", "")

    ;Parse GIT status
    stagedFiles := []
    stopdupli := Map()
    
    for line in gitStatus_list
    {

        If (RegExMatch(line,"^[^ ] *(.*)", &t)==0)
        {
            continue
        }
        t := t[1]
        
        ;ToolTip Format("out : {1}", test[1])d
        ;SetTimer () => ToolTip(), -5000
        If (InStr(t,"EasyB") and InStr(t,"source")){
            SplitPath t, &name, &dir, &ext, &name_no_ext, &drive
            res := StrSplit(name, ".", "")[1]
            If(NOT stopdupli.Has(res))
            {
                stopdupli[res] := res
            }
        }
        else if(InStr(t,"GNA") and InStr(t,"source")){
            SplitPath t, &name, &dir, &ext, &name_no_ext, &drive
            res := name
            If(NOT stopdupli.Has(res))
            {
                stopdupli[res] := res
            }
        }
    }

    for a, b in stopdupli{
        stagedFiles.Push(a)
    }

    ;Organize GIT status
    BuildValues(stagedFiles)

    ToolTip Format("Found : {1}", stagedFiles.Length)
    SetTimer () => ToolTip(), -5000
}

UpdateCommitList(in_SHA){
    if(in_SHA == "") {
        GetOldCommit("", true)
    }
    else {
        GetOldCommit(in_SHA)
    }
}

