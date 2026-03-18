name: ASP.NET Core CI Template

on:
  workflow_call:
    inputs:
      dotnet-version:
        description: '.NET version to use'
        required: false
        type: string
        default: '6.0.x'
      build-configuration:
        description: 'Build configuration'
        required: false
        type: string
        default: 'Release'
      dotnet-framework:
        description: '.NET framework target'
        required: false
        type: string
        default: 'net6.0'
      project-pattern:
        description: 'Project file pattern'
        required: false
        type: string
        default: '**/*.csproj'
      test-project-pattern:
        description: 'Test project file pattern'
        required: false
        type: string
        default: '**/*Tests.csproj'
      artifact-name:
        description: 'Name for the build artifact'
        required: false
        type: string
        default: 'drop'
      publish-path:
        description: 'Path to publish artifacts'
        required: false
        type: string
        default: './publish'
    outputs:
      artifact-name:
        description: 'Name of the uploaded artifact'
        value: ${{ jobs.build.outputs.artifact-name }}

env:
  BUILD_CONFIGURATION: ${{ inputs.build-configuration }}
  DOTNET_FRAMEWORK: ${{ inputs.dotnet-framework }}
  DOTNET_VERSION: ${{ inputs.dotnet-version }}

jobs:
  build:
    runs-on: ubuntu-latest
    
    outputs:
      artifact-name: ${{ steps.upload-artifact.outputs.artifact-id }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup .NET Core SDK
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}
    
    - name: Restore NuGet packages
      run: dotnet restore ${{ inputs.project-pattern }}
    
    - name: Build solution
      run: dotnet build ${{ inputs.project-pattern }} --configuration ${{ env.BUILD_CONFIGURATION }} --no-restore
    
    - name: Run unit tests
      run: dotnet test ${{ inputs.test-project-pattern }} --configuration ${{ env.BUILD_CONFIGURATION }} --no-build --collect "Code coverage"
    
    - name: Publish application
      run: dotnet publish ${{ inputs.project-pattern }} --configuration ${{ env.BUILD_CONFIGURATION }} --output ${{ inputs.publish-path }}
    
    - name: Upload build artifacts
      id: upload-artifact
      uses: actions/upload-artifact@v4
      with:
        name: ${{ inputs.artifact-name }}
        path: ${{ inputs.publish-path }}