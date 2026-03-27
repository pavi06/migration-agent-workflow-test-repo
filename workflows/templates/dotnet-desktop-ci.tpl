name: dotnet-desktop-ci-template

on:
  workflow_call:
    inputs:
      build-configuration:
        description: 'Build configuration (Debug/Release)'
        required: false
        type: string
        default: 'Release'
      build-platform:
        description: 'Build platform'
        required: false
        type: string
        default: 'Any CPU'
      solution-path:
        description: 'Path to solution file'
        required: false
        type: string
        default: '**/*.sln'
      dotnet-version:
        description: '.NET version to use'
        required: false
        type: string
        default: '6.0.x'
      nuget-version:
        description: 'NuGet version to use'
        required: false
        type: string
        default: '4.4.1'

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: ${{ inputs.dotnet-version }}

    - name: Setup NuGet
      uses: nuget/setup-nuget@v2
      with:
        nuget-version: ${{ inputs.nuget-version }}

    - name: Restore NuGet packages
      uses: pavi06/my-custom-github-actions-test/nuget-restore@main
      with:
        solution: ${{ inputs.solution-path }}
        verbosity: 'Detailed'

    - name: Build solution
      uses: pavi06/my-custom-github-actions-test/dotnet-build@main
      with:
        solution: ${{ inputs.solution-path }}
        configuration: ${{ inputs.build-configuration }}
        platform: ${{ inputs.build-platform }}

    - name: Run tests
      uses: pavi06/my-custom-github-actions-test/dotnet-test@main
      with:
        configuration: ${{ inputs.build-configuration }}
        platform: ${{ inputs.build-platform }}
        test-assembly-pattern: '**/${{ inputs.build-configuration }}/*test*.dll'
        exclude-pattern: '!**/obj/**'

    - name: Copy build artifacts
      uses: pavi06/my-custom-github-actions-test/copy-artifacts@main
      with:
        source-folder: ${{ github.workspace }}
        contents: '**/bin/${{ inputs.build-configuration }}/**'
        target-folder: ${{ github.workspace }}/artifacts

    - name: Upload build artifacts
      uses: actions/upload-artifact@v4
      if: always()
      with:
        name: build-artifacts
        path: ${{ github.workspace }}/artifacts
        retention-days: 30