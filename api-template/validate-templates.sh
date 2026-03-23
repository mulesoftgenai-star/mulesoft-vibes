#!/bin/bash

# MuleSoft API Template Validation Script
# This script validates the template structure and configurations

echo "🔍 Validating MuleSoft API Templates..."
echo "======================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validation functions
validate_directory_structure() {
    echo -e "\n📁 Validating directory structure..."
    
    required_dirs=(
        "shared-resources"
        "experience-layer/src/main/mule"
        "process-layer/src/main/mule"
        "system-layer/customer/src/main/mule"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo -e "  ✅ ${GREEN}$dir${NC} - OK"
        else
            echo -e "  ❌ ${RED}$dir${NC} - Missing"
        fi
    done
}

validate_configuration_files() {
    echo -e "\n⚙️ Validating configuration files..."
    
    config_files=(
        "shared-resources/global.xml"
        "shared-resources/config.yaml"
        "shared-resources/secure-properties.yaml"
    )
    
    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo -e "  ✅ ${GREEN}$file${NC} - OK"
        else
            echo -e "  ❌ ${RED}$file${NC} - Missing"
        fi
    done
}

validate_pom_files() {
    echo -e "\n📦 Validating Maven POM files..."
    
    pom_files=(
        "experience-layer/pom.xml"
        "process-layer/pom.xml"
        "system-layer/customer/pom.xml"
    )
    
    for pom in "${pom_files[@]}"; do
        if [[ -f "$pom" ]]; then
            # Check if POM contains required elements
            if grep -q "<groupId>" "$pom" && grep -q "<artifactId>" "$pom" && grep -q "<version>" "$pom"; then
                echo -e "  ✅ ${GREEN}$pom${NC} - Valid"
            else
                echo -e "  ⚠️ ${YELLOW}$pom${NC} - Missing required elements"
            fi
        else
            echo -e "  ❌ ${RED}$pom${NC} - Missing"
        fi
    done
}

validate_mule_files() {
    echo -e "\n🔧 Validating Mule XML files..."
    
    mule_files=(
        "experience-layer/src/main/mule/order-experience-api.xml"
        "process-layer/src/main/mule/order-process-api.xml"
        "system-layer/customer/src/main/mule/customer-system-api.xml"
    )
    
    for mule_file in "${mule_files[@]}"; do
        if [[ -f "$mule_file" ]]; then
            # Basic XML validation
            if grep -q "<mule" "$mule_file" && grep -q "</mule>" "$mule_file"; then
                echo -e "  ✅ ${GREEN}$mule_file${NC} - Valid XML"
            else
                echo -e "  ⚠️ ${YELLOW}$mule_file${NC} - Invalid XML structure"
            fi
        else
            echo -e "  ❌ ${RED}$mule_file${NC} - Missing"
        fi
    done
}

validate_raml_references() {
    echo -e "\n📝 Validating RAML references..."
    
    raml_files=(
        "../raml/order-experience-api.raml"
        "../raml/order-process-api.raml"
        "../raml/customer-system-api.raml"
    )
    
    for raml in "${raml_files[@]}"; do
        if [[ -f "$raml" ]]; then
            echo -e "  ✅ ${GREEN}$raml${NC} - Available"
        else
            echo -e "  ❌ ${RED}$raml${NC} - Missing (required for APIKit)"
        fi
    done
}

generate_report() {
    echo -e "\n📊 Validation Summary"
    echo "===================="