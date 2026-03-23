name: ASP.NET Core CI Template (Custom Actions)

on:
  workflow_call:
    inputs:
      dotnet-version:
        description: '.NET version to use'
        required: false
        type: string
        default: '8.0.x'
      build-configuration:
        description: 'Build configuration'
        required: false
        type: string
        default: 'Release'
      project-pattern:
        description: 'Project file pattern'
        required: false
        type: string
        default: '**/*.csproj'
      test-project-pattern:
        description: 'Test project file pattern'
        required: false
        type: string
        default: '**/*Tests/*.csproj'
      artifact-name:
        description: 'Name for the build artifact'
        required: false
        type: string
        default: 'drop'
      publish-path:
        description: 'Path to publish artifacts'
        required: false
        type: string
        default: './artifacts'
      runner-os:
        description: 'Operating system for the runner'
        required: false
        type: string
        default: 'windows-2022'

env:
  BUILD_CONFIGURATION: ${{ inputs.build-configuration }}
  DOTNET_VERSION: ${{ inputs.dotnet-version }}

jobs:
  build:
    runs-on: ${{ inputs.runner-os }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}
    
    - name: Restore dependencies
      uses: pavi06/my-custom-github-actions-test/dotnet-restore@main
      with:
        projects: ${{ inputs.project-pattern }}
    
    - name: Build
      uses: pavi06/my-custom-github-actions-test/dotnet-build@main
      with:
        projects: ${{ inputs.project-pattern }}
        configuration: ${{ env.BUILD_CONFIGURATION }}
    
    - name: Test
      uses: pavi06/my-custom-github-actions-test/dotnet-test@main
      with:
        projects: ${{ inputs.test-project-pattern }}
        configuration: ${{ env.BUILD_CONFIGURATION }}
    
    - name: Publish
      uses: pavi06/my-custom-github-actions-test/dotnet-publish@main
      with:
        configuration: ${{ env.BUILD_CONFIGURATION }}
        output-path: ${{ inputs.publish-path }}
        publish-web-projects: 'true'
    
    - name: Upload build artifacts
      uses: actions/upload-artifact@v4
      with:
        name: ${{ inputs.artifact-name }}
        path: ${{ inputs.publish-path }}