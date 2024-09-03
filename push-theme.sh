#!/bin/bash

# Load environment variables from .env file
set -a
source .env
set +a

# Check if required environment variables are set
if [[ -z "$SHOPIFY_PASSWORD" || -z "$SHOPIFY_STORE" || -z "$THEME_ID" ]]; then
  echo "Error: Required environment variables are not set. Please check your .env file."
  exit 1
fi

# Function to push theme with retry logic
push_theme() {
  local attempt=0
  local max_attempts=5
  local delay=1

  while ((attempt < max_attempts)); do
    echo "Pushing theme (Attempt: $((attempt + 1))/$max_attempts)..."
    
    # Push theme to Shopify store
    shopify theme push --store "$SHOPIFY_STORE" --password "$SHOPIFY_PASSWORD" --theme "$THEME_ID" --allow-live
    
    # Check if push was successful
    if [ $? -eq 0 ]; then
      echo "Theme pushed successfully."
      return 0
    else
      echo "Error encountered. Retrying in $delay seconds..."
      sleep $delay
      attempt=$((attempt + 1))
      delay=$((delay * 2)) # Exponential backoff
    fi
  done

  echo "Failed to push theme after $max_attempts attempts."
  return 1
}

# Run the function
push_theme