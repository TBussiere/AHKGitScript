;==============TODO==============
;
; - Enable Edit already generated
; - Direct Edit Reten
;
;===============================

#Requires AutoHotkey v2.0

global Version := "v1.1"
global ScriptLink := "https://raw.githubusercontent.com/TBussiere/AHKGitScript/main/AutoGit.ahk"
global VersionLink := "https://raw.githubusercontent.com/TBussiere/AHKGitScript/main/version.txt"


global OutReten := ""
global pathToReten := ""
global gitCommand := "git status --porcelain"
global gitCommand_ForOldCommits := "git show --oneline --name-status {1}"

global ToClip := true

global combo_res := ""

global git_StageStruct := Map()



local_script := A_ScriptFullPath
CheckForUpdate() {
    global version
    remote_version := FetchRemoteVersion()
    
    ; If the remote version is newer, update the script
    if (remote_version != "" && remote_version != version) {
        Result := MsgBox("New version " remote_version " available. Do you want to update ?", "Update", 36)
        if(Result == "Yes"){
            UpdateScript()
            ToolTip "Updating.."
            SetTimer () => ToolTip(), -5000
        }
    }
}

FetchRemoteVersion() {
    RunWaitOne("curl.exe -s " VersionLink " -o remote_version.txt")
    remote_version := ""
    ; Read the remote version file
    if FileExist("remote_version.txt") {
        o_file := FileOpen("remote_version.txt", "rw")
        remote_version := o_file.Read()
        FileDelete("remote_version.txt")

        return Trim(remote_version)
    } else {
        return ""
    }
}

UpdateScript() {
    RunWaitOne("curl.exe -s " ScriptLink " -o new_script.ahk")
    
    ; Check if download was successful
    if FileExist("new_script.ahk") {
        FileMove("new_script.ahk", local_script, true) ; Overwrite the current script
        MsgBox "Script updated successfully. Restarting..."
        Run local_script
        ExitApp
    } else {
    }
}


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
    CheckForUpdate()
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
                if(RegExMatch(last_task[combo_res], "^\#\#\#\#.*1\.1\.([0-9]*)\.([0-9]*)\.", &lineMatch)){
                    index1 := lineMatch[1]
                    index2 := Integer(lineMatch[2])+1
                }
                else if(RegExMatch(last_task[combo_res], "^\#\#\#\#.*1\.1\.([0-9]*)\.([0-9]*)", &lineMatch)) {
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

