# Stripe S700 Donation App

This project is a web application that allows users to input custom donation amounts for a fundraising event, enabling self-service payments at the Stripe S700 terminal.

## Features

- User-friendly interface for entering custom donation amounts.
- Predefined donation amounts for quick selection.
- Real-time payment status updates.
- Integration with the Stripe S700 terminal for seamless payment processing.

## Project Structure

```
stripe-s700-donation-app
├── client                # Frontend application
│   ├── src               # Source files for the React app
│   │   ├── components     # React components
│   │   ├── services       # API and Stripe service functions
│   │   ├── utils          # Utility functions
│   │   ├── App.js         # Main application component
│   │   └── index.js       # Entry point of the React application
│   ├── public            # Public assets
│   └── package.json      # NPM configuration
├── server                # Backend application
│   ├── controllers        # Controllers for handling requests
│   ├── services           # Services for business logic
│   ├── models             # Database models
│   ├── routes             # API routes
│   ├── config             # Configuration files
│   ├── app.rb             # Main entry point for the server
│   └── Gemfile            # Ruby gems required for the server
├── config                # Configuration files for deployment
├── docker-compose.yml    # Docker configuration
├── Dockerfile            # Docker image build instructions
└── README.md             # Project documentation
```

## Getting Started

### Prerequisites

- Ruby (version 2.7 or higher)
- Node.js (version 14 or higher)
- Docker (optional, for containerized deployment)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/stripe-s700-donation-app.git
   cd stripe-s700-donation-app
   ```

2. Set up the server:
   - Navigate to the `server` directory.
   - Install the required gems:
     ```
     bundle install
     ```

3. Set up the client:
   - Navigate to the `client` directory.
   - Install the required npm packages:
     ```
     npm install
     ```

4. Configure your environment variables for Stripe and database settings.

### Running the Application

- To start the server:
  ```
  cd server
  ruby app.rb
  ```

- To start the client:
  ```
  cd client
  npm start
  ```

### Deployment

For deployment, you can use Docker. Build and run the containers using:
```
docker-compose up --build
```

## Usage

- Users can enter custom donation amounts or select from predefined options.
- Payments are processed through the Stripe S700 terminal.
- Payment status is displayed in real-time.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.