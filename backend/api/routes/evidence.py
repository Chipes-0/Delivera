from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from uuid import UUID
from app.dependencies.db import get_db
from app.models import Evidence, Delivery

router = APIRouter(prefix="/evidence", tags=["Evidence"])


@router.post("/delivery/{delivery_id}/evidence")
def add_evidence(
    delivery_id: UUID,
    evidence: dict,
    db: Session = Depends(get_db)
):

    delivery = db.query(Delivery).filter(
        Delivery.id == delivery_id
    ).first()

    if not delivery:
        return {
            "success": False,
            "message": "Delivery not found"
        }

    created_evidences = []

    evidences = evidence.get("evidences")

    if not evidences:
        evidences = [evidence]

    for ev in evidences:

        new_evidence = Evidence(
            delivery_id=delivery_id,
            signature=ev.get("signature"),
            photo=ev.get("photo"),
            title=ev.get("title")
        )

        db.add(new_evidence)
        created_evidences.append(new_evidence)

    db.commit()

    for ev in created_evidences:
        db.refresh(ev)

    return {
        "success": True,
        "message": f"{len(created_evidences)} evidences created",
        "data": [
            {
                "id": str(ev.id),
                "delivery_id": str(ev.delivery_id),
                "signature": ev.signature,
                "photo": ev.photo,
                "title": ev.title,
                "created_at": ev.created_at.isoformat()
                if ev.created_at else None
            }
            for ev in created_evidences
        ]
    }


@router.get("/delivery/{delivery_id}/evidence")
def get_delivery_evidence(delivery_id: UUID, db: Session = Depends(get_db)):

    evidence_list = db.query(Evidence).filter(
        Evidence.delivery_id == delivery_id
    ).all()

    data = [
        {
            "id": str(e.id),
            "delivery_id": str(e.delivery_id),
            "signature": e.signature,
            "photo": e.photo,
            "created_at": e.created_at.isoformat() if e.created_at else None
        }
        for e in evidence_list
    ]

    return {
        "success": True,
        "data": data,
        "count": len(data)
    }


@router.get("/delivery/{delivery_id}/evidence/{evidence_id}")
def get_single_evidence(
    delivery_id: UUID,
    evidence_id: int,
    db: Session = Depends(get_db)
):

    evidence = db.query(Evidence).filter(
        Evidence.id == evidence_id,
        Evidence.delivery_id == delivery_id
    ).first()

    if not evidence:
        return {
            "success": False,
            "message": "Evidence not found"
        }

    return {
        "success": True,
        "data": {
            "id": str(evidence.id),
            "delivery_id": str(evidence.delivery_id),
            "signature": evidence.signature,
            "photo": evidence.photo,
            "created_at": evidence.created_at.isoformat() if evidence.created_at else None
        }
    }
    
@router.delete("/delivery/{delivery_id}/evidences/{evidence_id}")
def delete_evidence(
    delivery_id: UUID,
    evidence_id: int,
    db: Session = Depends(get_db)
):

    evidence = db.query(Evidence).filter(
        Evidence.id == evidence_id,
        Evidence.delivery_id == delivery_id
    ).first()

    if not evidence:
        return {
            "success": False,
            "message": "Evidence not found"
        }

    db.delete(evidence)
    db.commit()

    return {
        "success": True,
        "message": f"Evidence {evidence_id} deleted successfully"
    }
    
    