name: Multi-Environment Deployment Template

on:
  workflow_call:
    inputs:
      environments:
        description: 'Environments to deploy (JSON array)'
        required: false
        type: string
        default: '["dev", "stg", "prod"]'
      runner-os:
        description: 'Runner operating system'
        required: false
        type: string
        default: 'windows-latest'
      deployment-script:
        description: 'Custom deployment script to run'
        required: false
        type: string
        default: ''
    outputs:
      deployed-environments:
        description: 'List of environments that were deployed to'
        value: ${{ jobs.deploy.outputs.environments }}

jobs:
  deploy:
    strategy:
      matrix:
        environment: ${{ fromJson(inputs.environments) }}
    runs-on: ${{ inputs.runner-os }}
    environment: ${{ matrix.environment }}
    
    outputs:
      environments: ${{ strategy.job-total }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Display environment information
      run: |
        echo ####################################
        echo Current Environment - ${{ matrix.environment }}
        echo ####################################
      shell: bash
      
    - name: Run custom deployment script
      if: ${{ inputs.deployment-script != '' }}
      run: ${{ inputs.deployment-script }}
      shell: bash
      env:
        ENVIRONMENT: ${{ matrix.environment }}
        
    - name: Environment deployment summary
      run: |
        echo "Successfully processed deployment for environment: ${{ matrix.environment }}"
        echo "Runner OS: ${{ inputs.runner-os }}"
        echo "Timestamp: $(date)"
      shell: bash