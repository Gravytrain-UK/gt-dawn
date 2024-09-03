# .github/workflows/deploy-shopify-theme.yml

name: Deploy Shopify Theme

on:
  push:
    branches:
      - main
      - feature/github-actions # Replace with your branch name as needed

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Install Shopify CLI Dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y ruby-full ruby-bundler ruby-dev build-essential

    - name: Install Shopify CLI
      run: |
        echo "Installing Shopify CLI..."
        gem install --user-install shopify-cli
        # Dynamically add Ruby Gems to PATH
        echo "PATH=$(ruby -e 'print Gem.user_dir')/bin:$PATH" >> $GITHUB_ENV

    - name: Deploy to Shopify
      env:
        SHOPIFY_PASSWORD: ${{ secrets.SHOPIFY_PASSWORD }}
        SHOPIFY_STORE: ${{ secrets.SHOPIFY_STORE }}
        THEME_ID: ${{ secrets.THEME_ID }}
      run: |
        # Load the updated PATH
        source $GITHUB_ENV

        # Check Shopify CLI version
        shopify version

        # Retry logic to push theme to Shopify store
        attempt=0
        max_attempts=5
        delay=1

        while [ $attempt -lt $max_attempts ]; do
          echo "Pushing theme (Attempt: $((attempt + 1))/$max_attempts)..."
          if shopify theme push --password="$SHOPIFY_PASSWORD" --store="$SHOPIFY_STORE" --theme-id="$THEME_ID" --allow-live; then
            echo "Theme pushed successfully."
            break
          else
            echo "Error encountered. Retrying in $delay seconds..."
            sleep $delay
            attempt=$((attempt + 1))
            delay=$((delay * 2)) # Exponential backoff
          fi
        done

        if [ $attempt -eq $max_attempts ]; then
          echo "Failed to push theme after $max_attempts attempts."
          exit 1
        fi