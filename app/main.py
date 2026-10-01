from fastapi import FastAPI

app = FastAPI(title="ECS Fargate DevOps Demo")


@app.get("/")
def root():
    return {
        "message": "ECS Fargate deployment successful",
        "service": "ecs-fargate-devops"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }
