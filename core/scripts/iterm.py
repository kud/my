#!/usr/bin/env python3
"""
iTerm2 Python API helper.

Environment variables:
  ITERM_ACTION    — pane | tab (default: pane)
  ITERM_VERTICAL  — true | false  (default: true → split right; false → split below)
  ITERM_CMD       — command to run in the new session (optional)
"""

import iterm2
import os

ACTION = os.environ.get("ITERM_ACTION", "pane")
VERTICAL = os.environ.get("ITERM_VERTICAL", "true") == "true"
CMD = os.environ.get("ITERM_CMD", "")


async def main(connection):
    app = await iterm2.async_get_app(connection)
    window = app.current_terminal_window

    if not window:
        print("iterm: no open window found", flush=True)
        return

    if ACTION == "pane":
        session = window.current_tab.current_session
        new = await session.async_split_pane(vertical=VERTICAL)
    elif ACTION == "tab":
        tab = await window.async_create_tab()
        new = tab.current_session
    else:
        print(f"iterm: unknown action '{ACTION}'", flush=True)
        return

    if CMD:
        await new.async_send_text(CMD + "\n")


iterm2.run_until_complete(main)
