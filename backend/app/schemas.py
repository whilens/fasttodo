from pydantic import BaseModel, ConfigDict, Field, field_validator

# class OperationRequest(BaseModel):
#     wallet_name: str = Field(..., max_length=125)
#     amount: float

#     @field_validator('amount')
#     def amount_must_be_positive(cls, v: float) -> float:
#         if v <= 0:
#             raise ValueError("Amount must be positive")
#         return v

#     @field_validator('wallet_name')
#     def wallet_name_must_not_be_empty(cls, v: str) -> str:
#         v= v.strip()
#         if not v:
#             raise ValueError("Wallet name must not be empty")
#         return v

class PostCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=125)
    content: str = Field(..., min_length=3, max_length=1024)
    published: bool = False

class PostResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    content: str
    published: bool

class PostUpdate(BaseModel):
    title: str = Field(..., min_length=3, max_length=125)
    content: str = Field(..., min_length=3, max_length=1024)