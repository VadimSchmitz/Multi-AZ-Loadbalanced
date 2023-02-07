# Use an existing node image as the base image
FROM node:18-alpine
RUN apk add --no-cache libc6-compat git

# Set the working directory

# Clone the Multi-AZ-Loadbalanced-Next-App repository
RUN git clone https://github.com/VadimSchmitz/Multi-AZ-Loadbalanced-Next-App.git 
WORKDIR /Multi-AZ-Loadbalanced-Next-App


# Install the dependencies
RUN npm ci

# Build the application
RUN npm run build

# Expose port 3000 for the application to run on
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
