from fastapi import FastAPI 
from fastapi.middleware.cors import CORSMiddleware 
from dotenv import load_dotenv 
import os

from app.api import recipes, nutrition, favorites, history, users

load_dotenv()

# CORS origins - add Flutter app origins
origins = [ 
    "http://localhost:3000", 
    "http://localhost:8000", 
    "http://127.0.0.1:3000", 
    "http://127.0.0.1:8000",
    "http://localhost:*",  # Flutter web
    "*",  # Allow all origins for development (change in production)
]

app = FastAPI( 
    title="Smart Cooking Helper API", 
    description="AI-powered cooking assistance API", 
    version="1.0.0", 
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)
#Include routers
app.include_router(recipes.router, prefix="/api/recipes", tags=["recipes"]) 
app.include_router(nutrition.router, prefix="/api/nutrition", tags=["nutrition"]) 
app.include_router(favorites.router, prefix="/api/favorites", tags=["favorites"]) 
app.include_router(history.router, prefix="/api/history", tags=["history"]) 
app.include_router(users.router, prefix="/api/users", tags=["users"])
@app.get("/") 
async def root(): 
    return { "message": "Welcome to Smart Cooking Helper API", 
            "version": "1.0.0", 
            "docs": "/docs", 
            }
@app.get("/health") 
async def health_check(): 
    return {"status": "healthy"}
if __name__ == "__main__": 
    import uvicorn 
    uvicorn.run(app, host="0.0.0.0", port=8000)