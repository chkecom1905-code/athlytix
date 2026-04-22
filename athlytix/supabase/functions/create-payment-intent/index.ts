// supabase/functions/create-payment-intent/index.ts
// Deploy: supabase functions deploy create-payment-intent
// Add env: supabase secrets set STRIPE_SECRET_KEY=sk_live_...

import Stripe from 'npm:stripe@14';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
  apiVersion: '2024-04-10',
});

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { amount = 499, currency = 'eur', userId } = await req.json();

    // Create a Stripe customer or look up existing
    const paymentIntent = await stripe.paymentIntents.create({
      amount,            // 499 = 4.99€ in cents
      currency,
      metadata: { userId: userId ?? 'unknown' },
      automatic_payment_methods: { enabled: true },
    });

    return new Response(
      JSON.stringify({ clientSecret: paymentIntent.client_secret }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
