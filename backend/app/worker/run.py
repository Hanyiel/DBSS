from __future__ import annotations

from app.core.settings import get_settings
from app.services.sync import iter_forever


def main() -> int:
    settings = get_settings()
    source = settings.sync_source_db

    try:
        for tick in iter_forever(source, poll_seconds=settings.sync_poll_seconds, limit=50):
            pulled = tick.get("pulled", 0)
            if tick.get("error"):
                print(f"[worker] source={source} error={tick.get('error')}")
            if pulled:
                print(f"[worker] source={source} pulled={pulled} seconds={tick.get('seconds'):.3f}")
    except KeyboardInterrupt:
        return 0
    return 0
