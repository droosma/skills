# Worked examples

Three full walkthroughs: detect → judge → golden question → SBI rewrite. Read
`SKILL.md` first for the method these follow.

---

## Example 1 — A 360 feedback line (Dutch)

**Original:** *"Duncan neemt veel eigenaarschap en is heel professioneel."*

**Detect.** *eigenaarschap* and *professioneel* both fail the camera test — you
can't film either. *veel* and *heel* are empty intensifiers stacked on top.

**Judge.** No behaviour anywhere in the sentence. Both are ungrounded
conclusions. Flag both.

**Golden question.** *Waaraan zie je dat Duncan eigenaarschap neemt? Welk gedrag
maakt hem "professioneel"?*

**Answers (from the reviewer):** hij signaleert risico's vroeg; hij komt met een
voorstel voordat anderen erom vragen; hij komt voorbereid en koppelt terug
zonder dat je erom vraagt.

**SBI rewrite:**
> *Duncan signaleert risico's vroeg, betrekt de juiste stakeholders en komt met
> een uitgewerkt voorstel voordat anderen erom vragen. Hij komt voorbereid in
> refinements en koppelt uit zichzelf terug op openstaande punten.*

Now it's observable — you can confirm it, dispute it, and coach on it.

---

## Example 2 — A framework criterion (the trigger case)

**Original criterion:** *"De engineer heeft de backlog onder controle."*

**Detect.** *controle* is the container. A criterion people are assessed against
that can't be observed can't be assessed fairly — everyone scores it by feel.

**Judge.** Standalone conclusion, nothing grounded. Flag it. (For a *criterion*,
"ask the golden question" becomes "define the observable bar in the framework
itself.")

**Golden question → observable bar:** *Wat zie je een engineer doen als de
backlog onder controle is? Wat zou anders zijn als dat níet zo was?*

**Rewrite (criterion as filmable behaviour):**
> *Stories blijven gemiddeld minder dan twee sprints open; stakeholders weten op
> elk moment wat de hoogste prioriteit is; refinements zijn voorbereid; er komen
> nauwelijks verrassingen uit de backlog in productie.*

Each clause is checkable, so two assessors would grade it the same way.

---

## Example 3 — English, with an over-flag caught

**Original:** *"She shows strong ownership of quality, and the collaboration on
her team is good."*

**Detect.** *strong*, *ownership*, *quality*, *collaboration*, *good* all fail
the camera test.

**Judge.** Every one is ungrounded — nothing here is filmable. Flag the sentence
wholesale.

**Golden question.** *What do you see her doing that shows ownership of quality?
What happens between people that makes the collaboration "good"?*

**Answers:** she blocks merges that skip review; she writes a failing test before
fixing a bug; she pairs with teammates when they hit blockers and shares context
in the channel.

**SBI rewrite:**
> *She blocks any merge that skips code review and writes a reproducing test
> before fixing a bug, so regressions rarely ship. When a teammate is blocked she
> pairs with them and posts the resolution in the channel, so the fix is
> reusable.*

**Contrast — leave this one alone.** *"She shows strong ownership: she blocks
merges that skip review and writes a failing test before every fix."* Here
*ownership* is a headline immediately grounded in filmable behaviour. Don't
strip it — that's the ladder of abstraction working correctly.
