#!/usr/bin/env python3
"""Export visible user/assistant messages from explicitly selected local Codex logs.
No hidden reasoning, system/developer messages, credentials or tool dumps are exported.
No network. Local-only output; supply input paths explicitly to avoid unrelated tasks.
Uses reportlab only for optional PDF; preserved JSON+Markdown require stdlib only.
"""
from pathlib import Path
import argparse, json, datetime, hashlib, html
p=argparse.ArgumentParser();p.add_argument('sessions',type=Path,nargs='+');p.add_argument('--output',type=Path,required=True);p.add_argument('--pdf',action='store_true');p.add_argument('--font',type=Path);a=p.parse_args()
a.output.mkdir(parents=True,exist_ok=True)
for session in a.sessions:
    messages=[]
    for raw in session.read_text().splitlines():
        try:x=json.loads(raw)
        except json.JSONDecodeError:continue
        y=x.get('payload',{})
        if x.get('type')!='response_item' or y.get('type')!='message' or y.get('role') not in ('user','assistant'):continue
        if y.get('channel')=='analysis':continue
        parts=[c.get('text','') for c in y.get('content',[]) if c.get('type') in ('input_text','output_text','text')]
        text='\n'.join(parts)
        if not text:continue
        messages.append({'timestamp':x.get('timestamp'), 'role':y['role'],'channel':y.get('channel'),'text':text})
    name=session.stem
    meta={'source_file':session.name,'source_sha256_at_export':hashlib.sha256(session.read_bytes()).hexdigest(),'exported_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'Visible user and assistant text available in this local log. No hidden reasoning or system/developer instructions. Tools excluded; test evidence separate. Attachments retain references; original files separately preserved. Current active task is a cutoff snapshot, not a completed conversation.','messages':messages}
    (a.output/(name+'.json')).write_text(json.dumps(meta,indent=2,ensure_ascii=False)+'\n')
    md='# Project conversation transcript\n\n'+meta['scope']+'\n\nExported: '+meta['exported_utc']+'\n\n'+'\n\n'.join('## '+m['role']+' | '+str(m['timestamp'])+'\n\n'+m['text'] for m in messages)
    (a.output/(name+'.md')).write_text(md)
    if a.pdf:
        from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,Preformatted
        from reportlab.lib.styles import getSampleStyleSheet,ParagraphStyle
        from reportlab.lib.pagesizes import A4
        styles=getSampleStyleSheet()
        if a.font:
            from reportlab.pdfbase import pdfmetrics
            from reportlab.pdfbase.ttfonts import TTFont
            pdfmetrics.registerFont(TTFont('TranscriptFont',str(a.font)))
            for style in styles.byName.values(): style.fontName='TranscriptFont'
        body=ParagraphStyle('Transcript',parent=styles['BodyText'],fontSize=8,leading=11,spaceAfter=6,wordWrap='CJK')
        story=[Paragraph('Project conversation transcript',styles['Title']),Paragraph(html.escape(meta['scope']),body),Paragraph('Exported UTC: '+meta['exported_utc'],body)]
        for m in messages:
            story.append(Paragraph(m['role']+' | '+str(m['timestamp']),styles['Heading2']))
            # Preserve every text line, escape markup; no summary or invented exchanges.
            for line in m['text'].splitlines():
                story.append(Paragraph(html.escape(line) or '&#160;',body))
        def footer(c,d):
            c.setFont('Helvetica',8);c.drawString(36,22,'Project transcript - visible text snapshot');c.drawRightString(A4[0]-36,22,str(d.page))
        SimpleDocTemplate(str(a.output/(name+'.pdf')),pagesize=A4,rightMargin=36,leftMargin=36,topMargin=36,bottomMargin=36).build(story,onFirstPage=footer,onLaterPages=footer)
    print(name,len(messages),'visible messages exported')
