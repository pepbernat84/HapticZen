import argparse
import os
import hashlib
import json
import re
from typing import Optional

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.join(ROOT_DIR, "HapticZen.xcodeproj")
PBXPROJ_PATH = os.path.join(PROJECT_DIR, "project.pbxproj")

def resolve_team_id(cli_team_id: Optional[str]) -> str:
    """Resolve Apple Developer Team ID from CLI flag, environment, or existing pbxproj."""
    if cli_team_id is not None:
        return cli_team_id.strip()

    env_team = os.environ.get("DEVELOPMENT_TEAM", "").strip()
    if env_team:
        return env_team

    if os.path.exists(PBXPROJ_PATH):
        with open(PBXPROJ_PATH, "r", encoding="utf-8") as f:
            content = f.read()
        match = re.search(r"DEVELOPMENT_TEAM\s*=\s*([A-Z0-9]+);", content)
        if match:
            return match.group(1)

    return ""

def gen_uuid(key: str) -> str:
    return hashlib.md5(key.encode("utf-8")).hexdigest()[:24].upper()

def get_file_type(filename: str) -> str:
    if filename.endswith(".swift"):
        return "sourcecode.swift"
    elif filename.endswith(".xcassets"):
        return "folder.assetcatalog"
    elif filename.endswith(".xcstrings"):
        return "text.json.xcstrings"
    elif filename.endswith(".ahap"):
        return "text.json"
    elif filename.endswith(".caf"):
        return "audio.aiff"
    elif filename.endswith(".plist") or filename.endswith(".entitlements") or filename.endswith(".xcprivacy"):
        return "text.plist.xml"
    elif filename.endswith(".storekit"):
        return "file.storekit"
    return "text"

def scan_dir(base_dir, current_path=""):
    items = []
    full_path = os.path.join(base_dir, current_path)
    if not os.path.exists(full_path):
        return items
    for name in sorted(os.listdir(full_path)):
        if name.startswith(".") or name == "generate_project.py" or name.endswith(".xcodeproj"):
            continue
        rel_path = os.path.join(current_path, name) if current_path else name
        abs_path = os.path.join(base_dir, rel_path)
        if os.path.isdir(abs_path):
            if name.endswith(".xcassets"):
                items.append({"name": rel_path, "type": "asset", "basename": rel_path})
            else:
                sub_items = scan_dir(base_dir, rel_path)
                items.extend(sub_items)
        else:
            items.append({"name": rel_path, "type": "file", "basename": rel_path})
    return items

def create_pbxproj(team_id: str = ""):
    os.makedirs(PROJECT_DIR, exist_ok=True)
    target_attr_team_line = f"\n\t\t\t\t\t\tDevelopmentTeam = {team_id};" if team_id else ""
    build_setting_team_line = f"\n\t\t\t\tDEVELOPMENT_TEAM = {team_id};" if team_id else ""
    
    app_files = scan_dir(os.path.join(ROOT_DIR, "HapticZen"))
    test_files = scan_dir(os.path.join(ROOT_DIR, "HapticZenTests"))
    widget_files = scan_dir(os.path.join(ROOT_DIR, "HapticZenWidgets"))
    
    # Target and Project UUIDs
    target_uuid = gen_uuid("Target:HapticZen")
    tests_target_uuid = gen_uuid("Target:HapticZenTests")
    widgets_target_uuid = gen_uuid("Target:HapticZenWidgetsExtension")
    project_uuid = gen_uuid("Project:HapticZen")
    
    # Build configurations UUIDs
    app_config_list_uuid = gen_uuid("ConfigList:HapticZen")
    app_debug_config_uuid = gen_uuid("Config:HapticZen:Debug")
    app_release_config_uuid = gen_uuid("Config:HapticZen:Release")
    
    tests_config_list_uuid = gen_uuid("ConfigList:HapticZenTests")
    tests_debug_config_uuid = gen_uuid("Config:HapticZenTests:Debug")
    tests_release_config_uuid = gen_uuid("Config:HapticZenTests:Release")
    
    widgets_config_list_uuid = gen_uuid("ConfigList:HapticZenWidgetsExtension")
    widgets_debug_config_uuid = gen_uuid("Config:HapticZenWidgetsExtension:Debug")
    widgets_release_config_uuid = gen_uuid("Config:HapticZenWidgetsExtension:Release")
    
    proj_config_list_uuid = gen_uuid("ConfigList:Project")
    proj_debug_config_uuid = gen_uuid("Config:Project:Debug")
    proj_release_config_uuid = gen_uuid("Config:Project:Release")
    
    # Build phases UUIDs
    app_sources_uuid = gen_uuid("Sources:HapticZen")
    app_resources_uuid = gen_uuid("Resources:HapticZen")
    app_frameworks_uuid = gen_uuid("Frameworks:HapticZen")
    embed_extensions_uuid = gen_uuid("CopyFiles:EmbedAppExtensions")
    
    tests_sources_uuid = gen_uuid("Sources:HapticZenTests")
    tests_resources_uuid = gen_uuid("Resources:HapticZenTests")
    tests_frameworks_uuid = gen_uuid("Frameworks:HapticZenTests")
    
    widgets_sources_uuid = gen_uuid("Sources:HapticZenWidgetsExtension")
    widgets_resources_uuid = gen_uuid("Resources:HapticZenWidgetsExtension")
    widgets_frameworks_uuid = gen_uuid("Frameworks:HapticZenWidgetsExtension")
    
    # Group UUIDs
    main_group_uuid = gen_uuid("Group:Main")
    app_group_uuid = gen_uuid("Group:HapticZen")
    tests_group_uuid = gen_uuid("Group:HapticZenTests")
    widgets_group_uuid = gen_uuid("Group:HapticZenWidgets")
    products_group_uuid = gen_uuid("Group:Products")
    
    app_product_uuid = gen_uuid("Product:HapticZen.app")
    tests_product_uuid = gen_uuid("Product:HapticZenTests.xctest")
    widgets_product_uuid = gen_uuid("Product:HapticZenWidgetsExtension.appex")
    
    target_dependency_uuid = gen_uuid("TargetDependency:HapticZenTests->HapticZen")
    container_item_proxy_uuid = gen_uuid("ContainerItemProxy:HapticZenTests->HapticZen")
    
    widgets_dependency_uuid = gen_uuid("TargetDependency:HapticZen->HapticZenWidgetsExtension")
    widgets_container_proxy_uuid = gen_uuid("ContainerItemProxy:HapticZen->HapticZenWidgetsExtension")
    widgets_embed_build_file_uuid = gen_uuid("BuildFile:EmbedAppExtensions:HapticZenWidgetsExtension.appex")
    
    # Build PBXFileReference and PBXBuildFile sections
    file_refs = []
    build_files = []
    
    app_source_build_files = []
    app_resource_build_files = []
    tests_source_build_files = []
    tests_resource_build_files = []
    widgets_source_build_files = []
    widgets_resource_build_files = []
    
    def get_or_create_group(path_parts, root_group_uuid, group_dict, prefix="App"):
        current_uuid = root_group_uuid
        current_path = ""
        for part in path_parts:
            current_path = f"{current_path}/{part}" if current_path else part
            group_key = f"{prefix}:{current_path}"
            if group_key not in group_dict:
                g_uuid = gen_uuid(f"Group:{group_key}")
                group_dict[group_key] = {
                    "uuid": g_uuid,
                    "name": part,
                    "path": part,
                    "children": [],
                    "parent": current_uuid
                }
                if current_uuid != root_group_uuid:
                    for k, v in group_dict.items():
                        if v["uuid"] == current_uuid:
                            v["children"].append(g_uuid)
                            break
            current_uuid = group_dict[group_key]["uuid"]
        return current_uuid

    app_groups = {}
    tests_groups = {}
    widgets_groups = {}
    
    # 1. Scan App Files
    app_file_uuids = []
    for item in app_files:
        rel_path = item["name"]
        parts = rel_path.replace("\\", "/").split("/")
        filename = parts[-1]
        dir_parts = parts[:-1]
        
        file_uuid = gen_uuid(f"FileRef:App:{rel_path}")
        build_file_uuid = gen_uuid(f"BuildFile:App:{rel_path}")
        file_type = get_file_type(filename)
        
        if dir_parts:
            parent_group_uuid = get_or_create_group(dir_parts, app_group_uuid, app_groups, "App")
            for k, v in app_groups.items():
                if v["uuid"] == parent_group_uuid:
                    v["children"].append(file_uuid)
                    break
        else:
            app_file_uuids.append(file_uuid)
            
        file_refs.append(f'\t\t{file_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = "{filename}"; sourceTree = "<group>"; }};')
        
        if filename.endswith(".swift"):
            build_files.append(f'\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {filename} */; }};')
            app_source_build_files.append(f'\t\t\t\t{build_file_uuid} /* {filename} in Sources */,')
        elif any(filename.endswith(ext) for ext in [".xcassets", ".xcstrings", ".ahap", ".caf", ".storekit", ".xcprivacy"]):
            build_files.append(f'\t\t{build_file_uuid} /* {filename} in Resources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {filename} */; }};')
            app_resource_build_files.append(f'\t\t\t\t{build_file_uuid} /* {filename} in Resources */,')
            if filename == "Localizable.xcstrings":
                w_loc_build_uuid = gen_uuid(f"BuildFile:WidgetsShared:{rel_path}")
                build_files.append(f'\t\t{w_loc_build_uuid} /* {filename} in Resources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {filename} */; }};')
                widgets_resource_build_files.append(f'\t\t\t\t{w_loc_build_uuid} /* {filename} in Resources */,')

    # 2. Scan Test Files
    tests_file_uuids = []
    for item in test_files:
        rel_path = item["name"]
        parts = rel_path.replace("\\", "/").split("/")
        filename = parts[-1]
        dir_parts = parts[:-1]
        
        file_uuid = gen_uuid(f"FileRef:Tests:{rel_path}")
        build_file_uuid = gen_uuid(f"BuildFile:Tests:{rel_path}")
        file_type = get_file_type(filename)
        
        if dir_parts:
            parent_group_uuid = get_or_create_group(dir_parts, tests_group_uuid, tests_groups, "Tests")
            for k, v in tests_groups.items():
                if v["uuid"] == parent_group_uuid:
                    v["children"].append(file_uuid)
                    break
        else:
            tests_file_uuids.append(file_uuid)
            
        file_refs.append(f'\t\t{file_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = "{filename}"; sourceTree = "<group>"; }};')
        
        if filename.endswith(".swift"):
            build_files.append(f'\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {filename} */; }};')
            tests_source_build_files.append(f'\t\t\t\t{build_file_uuid} /* {filename} in Sources */,')
        elif any(filename.endswith(ext) for ext in [".xcassets", ".xcstrings", ".ahap", ".caf", ".storekit"]):
            build_files.append(f'\t\t{build_file_uuid} /* {filename} in Resources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {filename} */; }};')
            tests_resource_build_files.append(f'\t\t\t\t{build_file_uuid} /* {filename} in Resources */,')

    # 3. Scan Widget Files
    widgets_file_uuids = []
    for item in widget_files:
        rel_path = item["name"]
        parts = rel_path.replace("\\", "/").split("/")
        filename = parts[-1]
        dir_parts = parts[:-1]
        
        file_uuid = gen_uuid(f"FileRef:Widgets:{rel_path}")
        build_file_uuid = gen_uuid(f"BuildFile:Widgets:{rel_path}")
        file_type = get_file_type(filename)
        
        if dir_parts:
            parent_group_uuid = get_or_create_group(dir_parts, widgets_group_uuid, widgets_groups, "Widgets")
            for k, v in widgets_groups.items():
                if v["uuid"] == parent_group_uuid:
                    v["children"].append(file_uuid)
                    break
        else:
            widgets_file_uuids.append(file_uuid)
            
        file_refs.append(f'\t\t{file_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = "{filename}"; sourceTree = "<group>"; }};')
        
        if filename.endswith(".swift"):
            build_files.append(f'\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {filename} */; }};')
            widgets_source_build_files.append(f'\t\t\t\t{build_file_uuid} /* {filename} in Sources */,')
        elif any(filename.endswith(ext) for ext in [".xcassets", ".xcstrings", ".ahap", ".caf", ".storekit", ".xcprivacy"]):
            build_files.append(f'\t\t{build_file_uuid} /* {filename} in Resources */ = {{isa = PBXBuildFile; fileRef = {file_uuid} /* {filename} */; }};')
            widgets_resource_build_files.append(f'\t\t\t\t{build_file_uuid} /* {filename} in Resources */,')

    # Add Product File References
    file_refs.append(f'\t\t{app_product_uuid} /* HapticZen.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = HapticZen.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
    file_refs.append(f'\t\t{tests_product_uuid} /* HapticZenTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = HapticZenTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};')
    file_refs.append(f'\t\t{widgets_product_uuid} /* HapticZenWidgetsExtension.appex */ = {{isa = PBXFileReference; explicitFileType = "wrapper.app-extension"; includeInIndex = 0; path = HapticZenWidgetsExtension.appex; sourceTree = BUILT_PRODUCTS_DIR; }};')

    # Build file for embedding widgets in app
    build_files.append(f'\t\t{widgets_embed_build_file_uuid} /* HapticZenWidgetsExtension.appex in Embed App Extensions */ = {{isa = PBXBuildFile; fileRef = {widgets_product_uuid} /* HapticZenWidgetsExtension.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};')

    # Add top level group children
    app_top_children = []
    for k, v in app_groups.items():
        if "/" not in k.split(":", 1)[1]:
            app_top_children.append(v["uuid"])
    app_top_children.extend(app_file_uuids)
    
    tests_top_children = []
    for k, v in tests_groups.items():
        if "/" not in k.split(":", 1)[1]:
            tests_top_children.append(v["uuid"])
    tests_top_children.extend(tests_file_uuids)

    widgets_top_children = []
    for k, v in widgets_groups.items():
        if "/" not in k.split(":", 1)[1]:
            widgets_top_children.append(v["uuid"])
    widgets_top_children.extend(widgets_file_uuids)

    # Format PBXGroup section
    pbx_groups = []
    pbx_groups.append(f'''\t\t{main_group_uuid} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_group_uuid} /* HapticZen */,
\t\t\t\t{widgets_group_uuid} /* HapticZenWidgets */,
\t\t\t\t{tests_group_uuid} /* HapticZenTests */,
\t\t\t\t{products_group_uuid} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};''')
    
    app_children_str = "\n".join([f"\t\t\t\t{c}," for c in app_top_children])
    pbx_groups.append(f'''\t\t{app_group_uuid} /* HapticZen */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{app_children_str}
\t\t\t);
\t\t\tpath = HapticZen;
\t\t\tsourceTree = "<group>";
\t\t}};''')

    widgets_children_str = "\n".join([f"\t\t\t\t{c}," for c in widgets_top_children])
    pbx_groups.append(f'''\t\t{widgets_group_uuid} /* HapticZenWidgets */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{widgets_children_str}
\t\t\t);
\t\t\tpath = HapticZenWidgets;
\t\t\tsourceTree = "<group>";
\t\t}};''')

    tests_children_str = "\n".join([f"\t\t\t\t{c}," for c in tests_top_children])
    pbx_groups.append(f'''\t\t{tests_group_uuid} /* HapticZenTests */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{tests_children_str}
\t\t\t);
\t\t\tpath = HapticZenTests;
\t\t\tsourceTree = "<group>";
\t\t}};''')

    pbx_groups.append(f'''\t\t{products_group_uuid} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_product_uuid} /* HapticZen.app */,
\t\t\t\t{tests_product_uuid} /* HapticZenTests.xctest */,
\t\t\t\t{widgets_product_uuid} /* HapticZenWidgetsExtension.appex */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};''')

    for k, v in {**app_groups, **widgets_groups, **tests_groups}.items():
        children_str = "\n".join([f"\t\t\t\t{c}," for c in v["children"]])
        pbx_groups.append(f'''\t\t{v["uuid"]} /* {v["name"]} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{children_str}
\t\t\t);
\t\t\tname = "{v["name"]}";
\t\t\tpath = "{v["path"]}";
\t\t\tsourceTree = "<group>";
\t\t}};''')

    file_refs_str = "\n".join(file_refs)
    build_files_str = "\n".join(build_files)
    pbx_groups_str = "\n".join(pbx_groups)
    
    app_source_build_files_str = "\n".join(app_source_build_files)
    app_resource_build_files_str = "\n".join(app_resource_build_files)
    tests_source_build_files_str = "\n".join(tests_source_build_files)
    tests_resource_build_files_str = "\n".join(tests_resource_build_files)
    widgets_source_build_files_str = "\n".join(widgets_source_build_files)
    widgets_resource_build_files_str = "\n".join(widgets_resource_build_files)
    
    pbx_content = f'''// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 56;
\tobjects = {{

/* Begin PBXBuildFile section */
{build_files_str}
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
\t\t{container_item_proxy_uuid} /* PBXContainerItemProxy */ = {{
\t\t\tisa = PBXContainerItemProxy;
\t\t\tcontainerPortal = {project_uuid} /* Project object */;
\t\t\tproxyType = 1;
\t\t\tremoteGlobalIDString = {target_uuid};
\t\t\tremoteInfo = HapticZen;
\t\t}};
\t\t{widgets_container_proxy_uuid} /* PBXContainerItemProxy */ = {{
\t\t\tisa = PBXContainerItemProxy;
\t\t\tcontainerPortal = {project_uuid} /* Project object */;
\t\t\tproxyType = 1;
\t\t\tremoteGlobalIDString = {widgets_target_uuid};
\t\t\tremoteInfo = HapticZenWidgetsExtension;
\t\t}};
/* End PBXContainerItemProxy section */

/* Begin PBXCopyFilesBuildPhase section */
\t\t{embed_extensions_uuid} /* Embed App Extensions */ = {{
\t\t\tisa = PBXCopyFilesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tdstPath = "";
\t\t\tdstSubfolderSpec = 13;
\t\t\tfiles = (
\t\t\t\t{widgets_embed_build_file_uuid} /* HapticZenWidgetsExtension.appex in Embed App Extensions */,
\t\t\t);
\t\t\tname = "Embed App Extensions";
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
{file_refs_str}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{app_frameworks_uuid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{tests_frameworks_uuid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{widgets_frameworks_uuid} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
{pbx_groups_str}
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{target_uuid} /* HapticZen */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {app_config_list_uuid} /* Build configuration list for PBXNativeTarget "HapticZen" */;
\t\t\tbuildPhases = (
\t\t\t\t{app_sources_uuid} /* Sources */,
\t\t\t\t{app_frameworks_uuid} /* Frameworks */,
\t\t\t\t{app_resources_uuid} /* Resources */,
\t\t\t\t{embed_extensions_uuid} /* Embed App Extensions */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\t{widgets_dependency_uuid} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = HapticZen;
\t\t\tproductName = HapticZen;
\t\t\tproductReference = {app_product_uuid} /* HapticZen.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
\t\t{tests_target_uuid} /* HapticZenTests */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {tests_config_list_uuid} /* Build configuration list for PBXNativeTarget "HapticZenTests" */;
\t\t\tbuildPhases = (
\t\t\t\t{tests_sources_uuid} /* Sources */,
\t\t\t\t{tests_frameworks_uuid} /* Frameworks */,
\t\t\t\t{tests_resources_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t\t{target_dependency_uuid} /* PBXTargetDependency */,
\t\t\t);
\t\t\tname = HapticZenTests;
\t\t\tproductName = HapticZenTests;
\t\t\tproductReference = {tests_product_uuid} /* HapticZenTests.xctest */;
\t\t\tproductType = "com.apple.product-type.bundle.unit-test";
\t\t}};
\t\t{widgets_target_uuid} /* HapticZenWidgetsExtension */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {widgets_config_list_uuid} /* Build configuration list for PBXNativeTarget "HapticZenWidgetsExtension" */;
\t\t\tbuildPhases = (
\t\t\t\t{widgets_sources_uuid} /* Sources */,
\t\t\t\t{widgets_frameworks_uuid} /* Frameworks */,
\t\t\t\t{widgets_resources_uuid} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = HapticZenWidgetsExtension;
\t\t\tproductName = HapticZenWidgetsExtension;
\t\t\tproductReference = {widgets_product_uuid} /* HapticZenWidgetsExtension.appex */;
\t\t\tproductType = "com.apple.product-type.app-extension";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{project_uuid} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastUpgradeCheck = 1500;
\t\t\t\tOrganizationName = HapticZen;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{target_uuid} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;{target_attr_team_line}
\t\t\t\t\t}};
\t\t\t\t\t{tests_target_uuid} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;{target_attr_team_line}
\t\t\t\t\t\tTestTargetID = {target_uuid};
\t\t\t\t\t}};
\t\t\t\t\t{widgets_target_uuid} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;{target_attr_team_line}
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {proj_config_list_uuid} /* Build configuration list for PBXProject "HapticZen" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tca,
\t\t\t\tes,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {main_group_uuid};
\t\t\tproductRefGroup = {products_group_uuid} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_uuid} /* HapticZen */,
\t\t\t\t{widgets_target_uuid} /* HapticZenWidgetsExtension */,
\t\t\t\t{tests_target_uuid} /* HapticZenTests */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{app_resources_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{app_resource_build_files_str}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{tests_resources_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{tests_resource_build_files_str}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{widgets_resources_uuid} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{widgets_resource_build_files_str}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{app_sources_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{app_source_build_files_str}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{tests_sources_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{tests_source_build_files_str}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
\t\t{widgets_sources_uuid} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
{widgets_source_build_files_str}
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
\t\t{target_dependency_uuid} /* PBXTargetDependency */ = {{
\t\t\tisa = PBXTargetDependency;
\t\t\ttarget = {target_uuid} /* HapticZen */;
\t\t\ttargetProxy = {container_item_proxy_uuid} /* PBXContainerItemProxy */;
\t\t}};
\t\t{widgets_dependency_uuid} /* PBXTargetDependency */ = {{
\t\t\tisa = PBXTargetDependency;
\t\t\ttarget = {widgets_target_uuid} /* HapticZenWidgetsExtension */;
\t\t\ttargetProxy = {widgets_container_proxy_uuid} /* PBXContainerItemProxy */;
\t\t}};
/* End PBXTargetDependency section */

/* Begin XCBuildConfiguration section */
\t\t{proj_debug_config_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{proj_release_config_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;
\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{app_debug_config_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = "HapticZen/HapticZen.entitlements";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;{build_setting_team_line}
\t\t\t\tDEVELOPMENT_ASSET_PATHS = "HapticZen/PreviewContent";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_FILE = "HapticZen/Info.plist";
\t\t\t\tINFOPLIST_KEY_NSHealthShareUsageDescription = "Haptic Zen links with Apple Health to track your mindful sessions and relaxation progress.";
\t\t\t\tINFOPLIST_KEY_NSHealthUpdateUsageDescription = "Haptic Zen saves your guided breathing and tactile relaxation sessions as Mindful Minutes in Apple Health.";
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = UIInterfaceOrientationPortrait;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.hapticzen.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{app_release_config_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = "HapticZen/HapticZen.entitlements";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;{build_setting_team_line}
\t\t\t\tDEVELOPMENT_ASSET_PATHS = "HapticZen/PreviewContent";
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_FILE = "HapticZen/Info.plist";
\t\t\t\tINFOPLIST_KEY_NSHealthShareUsageDescription = "Haptic Zen links with Apple Health to track your mindful sessions and relaxation progress.";
\t\t\t\tINFOPLIST_KEY_NSHealthUpdateUsageDescription = "Haptic Zen saves your guided breathing and tactile relaxation sessions as Mindful Minutes in Apple Health.";
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = UIInterfaceOrientationPortrait;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.hapticzen.app;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{widgets_debug_config_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = "HapticZenWidgets/HapticZenWidget.entitlements";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;{build_setting_team_line}
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "Haptic Zen";
\t\t\t\tINFOPLIST_FILE = "HapticZenWidgets/Info.plist";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t\t"@executable_path/../../Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "com.hapticzen.app.widget";
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{widgets_release_config_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tCODE_SIGN_ENTITLEMENTS = "HapticZenWidgets/HapticZenWidget.entitlements";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;{build_setting_team_line}
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "Haptic Zen";
\t\t\t\tINFOPLIST_FILE = "HapticZenWidgets/Info.plist";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = (
\t\t\t\t\t"$(inherited)",
\t\t\t\t\t"@executable_path/Frameworks",
\t\t\t\t\t"@executable_path/../../Frameworks",
\t\t\t\t);
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = "com.hapticzen.app.widget";
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSKIP_INSTALL = YES;
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t}};
\t\t\tname = Release;
\t\t}};
\t\t{tests_debug_config_uuid} /* Debug */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tBUNDLE_LOADER = "$(TEST_HOST)";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;{build_setting_team_line}
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.hapticzen.tests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = NO;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t\tTEST_HOST = "$(BUILT_PRODUCTS_DIR)/HapticZen.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/HapticZen";
\t\t\t}};
\t\t\tname = Debug;
\t\t}};
\t\t{tests_release_config_uuid} /* Release */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{
\t\t\t\tBUNDLE_LOADER = "$(TEST_HOST)";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;{build_setting_team_line}
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.hapticzen.tests;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = NO;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t\tTEST_HOST = "$(BUILT_PRODUCTS_DIR)/HapticZen.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/HapticZen";
\t\t\t}};
\t\t\tname = Release;
\t\t}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{proj_config_list_uuid} /* Build configuration list for PBXProject "HapticZen" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{proj_debug_config_uuid} /* Debug */,
\t\t\t\t{proj_release_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{app_config_list_uuid} /* Build configuration list for PBXNativeTarget "HapticZen" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{app_debug_config_uuid} /* Debug */,
\t\t\t\t{app_release_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{widgets_config_list_uuid} /* Build configuration list for PBXNativeTarget "HapticZenWidgetsExtension" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{widgets_debug_config_uuid} /* Debug */,
\t\t\t\t{widgets_release_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{tests_config_list_uuid} /* Build configuration list for PBXNativeTarget "HapticZenTests" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{tests_debug_config_uuid} /* Debug */,
\t\t\t\t{tests_release_config_uuid} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {project_uuid} /* Project object */;
}}
'''
    with open(PBXPROJ_PATH, "w", encoding="utf-8") as f:
        f.write(pbx_content)
        
    create_xcscheme(target_uuid, tests_target_uuid)
    print(f"Generated {PBXPROJ_PATH} successfully with {len(app_files)} app files, {len(widget_files)} widget files, and {len(test_files)} test files.")

def create_xcscheme(target_uuid: str, tests_target_uuid: str):
    scheme_dir = os.path.join(PROJECT_DIR, "xcshareddata", "xcschemes")
    os.makedirs(scheme_dir, exist_ok=True)
    scheme_path = os.path.join(scheme_dir, "HapticZen.xcscheme")
    scheme_xml = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.3">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{target_uuid}"
               BuildableName = "HapticZen.app"
               BlueprintName = "HapticZen"
               ReferencedContainer = "container:HapticZen.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{tests_target_uuid}"
               BuildableName = "HapticZenTests.xctest"
               BlueprintName = "HapticZenTests"
               ReferencedContainer = "container:HapticZen.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{target_uuid}"
            BuildableName = "HapticZen.app"
            BlueprintName = "HapticZen"
            ReferencedContainer = "container:HapticZen.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
      <StoreKitConfigurationFileReference
         identifier = "../../HapticZenTests/HapticZen.storekit">
      </StoreKitConfigurationFileReference>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{target_uuid}"
            BuildableName = "HapticZen.app"
            BlueprintName = "HapticZen"
            ReferencedContainer = "container:HapticZen.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
'''
    with open(scheme_path, "w", encoding="utf-8") as f:
        f.write(scheme_xml)
    print(f"Generated scheme at {scheme_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate HapticZen Xcode project and shared scheme.")
    parser.add_argument(
        "--team-id",
        default=None,
        help="Apple Developer Team ID (10-char alphanumeric). Pass empty string to clear."
    )
    args = parser.parse_args()
    resolved_team_id = resolve_team_id(args.team_id)
    create_pbxproj(team_id=resolved_team_id)
