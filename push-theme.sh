# Load environment variables from .env file
set -a
source .env
set +a

# Check if required environment variables are set
if [[ -z "$SHOPIFY_PASSWORD" || -z "$SHOPIFY_STORE" || -z "$THEME_ID" ]]; then
  echo "Error: Required environment variables are not set. Please check your .env file."
  exit 1
fi

# Retry logic to push theme to Shopify store
attempt=0
max_attempts=5
delay=1

while [ $attempt -lt $max_attempts ]; do
  echo "Pushing theme (Attempt: $((attempt + 1))/$max_attempts)..."
  if shopify theme push --store "$SHOPIFY_STORE" --password "$SHOPIFY_PASSWORD" --theme-id "$THEME_ID" --allow-live; then
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