# Jenkins with Docker Compose, HashiCorp Vault, SonarQube, and Ngrok

The purpose of this project is to demonstrate how to set up a Jenkins pipeline that incorporates various tools and technologies. The pipeline is designed to automate the build, test, and deployment processes of a software project.

Please note that users must have an understanding of how these technologies work in order to use them.

## Technologies

- Jenkins: Jenkins is an open-source automation server that allows you to automate various tasks, including building, testing, and deploying software projects.

- Docker Compose: Docker Compose is a tool that allows you to define and run multi-container Docker applications. It simplifies the process of managing and orchestrating multiple containers.

- HashiCorp Vault: HashiCorp Vault is a tool for securely storing and accessing secrets. It provides a centralized solution for managing sensitive information such as API keys, passwords, and certificates.

- SonarQube: SonarQube is an open-source platform for continuous code quality inspection. It helps identify and fix code quality issues, security vulnerabilities, and bugs.

- Ngrok: Ngrok is a tool that allows you to expose your local development server to the internet. It creates a secure tunnel between your local machine and the internet, making it easier to test and share your applications.

## Getting Started

To get started with this project, follow these steps:

1. Clone the repository: `git clone https://github.com/your-repo.git`

2. Clone the .env.example and rename it to .env

3. Make any necessary amendments, including configuring Ngrok and Vault and storing its settings
    - /ngrok - Store all the Ngrok configuration
    - /vault - Store all the HashiCorp Vault configuration

4. Install Docker Compose and make the necessary changes to the services and configurations in the `docker-compose.yml` file.

5. Run `docker compose up -d` to create all the service containers.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
